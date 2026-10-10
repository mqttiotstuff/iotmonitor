//
//  IOT Monitor - monitor and recover state for iot device and software agents
//
//  pfreydiere - 2019 - 2022
//

const std = @import("std");
const json = std.json;
const debug = std.debug;
const log = std.log;
const assert = debug.assert;
const mem = std.mem;
const version = @import("version.zig");

// used for sleep, and other, it may be removed
// to relax libC needs
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("unistd.h");
    @cInclude("signal.h");
    @cInclude("time.h");
    @cInclude("string.h");
    @cInclude("stdlib.h");
});

const leveldb = @import("leveldb.zig");
const mqtt = @import("mqttlib.zig");
const processlib = @import("processlib.zig");
const topics = @import("topics.zig");
const toml = @import("toml");
const clap = @import("clap");
const httpserver = @import("httpserver.zig");

// profiling, to check performance on functions
// this is mocked in the build.zig (activate this tracy library)
const tracy = @import("tracy");

var out_buffer: [4096]u8 = undefined;
var out_file_writer: std.Io.File.Writer = undefined;
var out: *std.Io.Writer = undefined;

const Verbose = false;

// This structure defines the process informations
// with live agent running, this permit to track the process and
// relaunch it if needed
//
const AdditionalProcessInformation = struct {
    // pid is to track the process while running
    pid: ?i32 = undefined,
    // process identifier attributed by IOTMonitor, to track existing processes
    // processIdentifier: []const u8 = "",
    exec: []const u8 = "",

    // last time the process is restarted
    lastRestarted: c.time_t = 0,

    // number of time, the process is restarted
    restartedCount: u64 = 0,
};

const MonitoringInfo = struct {
    // name of the device
    name: []const u8 = "",
    watchTopics: []const u8,
    nextContact: c.time_t,
    timeoutValue: u32 = 30,
    stateTopics: ?[]const u8 = null,
    helloTopic: ?[]const u8 = null,
    helloTopicCount: u64 = 0,
    allocator: mem.Allocator,

    // in case of process informations,
    // used to relaunch or not the process, permitting to
    // take a process out of the monitoring, and then reintegrate it
    enabled: bool = true,

    associatedProcessInformation: ?*AdditionalProcessInformation = null,

    fn init(allocator: mem.Allocator) !*MonitoringInfo {
        const device = try allocator.create(MonitoringInfo);
        device.allocator = allocator;
        device.stateTopics = null;
        device.helloTopic = null;
        device.helloTopicCount = 0;
        device.timeoutValue = 30;
        device.associatedProcessInformation = null;
        device.enabled = true;

        return device;
    }
    fn deinit(self: *MonitoringInfo) void {
        self.allocator.destroy(self);
    }

    fn updateNextContact(device: *MonitoringInfo) !void {
        _ = c.time(&device.*.nextContact);
        device.*.nextContact = device.*.nextContact + @as(c_long, @intCast(device.*.timeoutValue));
    }

    fn hasExpired(device: *MonitoringInfo) !bool {
        var currentTime: c.time_t = undefined;
        _ = c.time(&currentTime);
        const diff = c.difftime(currentTime, device.*.nextContact);
        if (diff > 0) return true;
        return false;
    }
};

fn stripLastWildCard(watchValue: []const u8) ![]const u8 {
    assert(watchValue.len > 0);
    if (watchValue[watchValue.len - 1] == '#') {
        return watchValue[0 .. watchValue.len - 2];
    }
    return watchValue;
}

test "test update time" {
    var d = MonitoringInfo{
        .timeoutValue = 1,
        .watchTopics = "",
        .nextContact = undefined,
        .allocator = undefined,
        .helloTopic = undefined,
        .stateTopics = undefined,
        .associatedProcessInformation = undefined,
    };
    try d.updateNextContact();
    _ = c.sleep(3);
    debug.assert(try d.hasExpired());

    d.timeoutValue = 20;
    try d.updateNextContact();

    _ = c.sleep(3);
    debug.assert(!try d.hasExpired());
}

pub fn secureZero(s: []u8) void {
    var i: u32 = 0;
    while (i < s.len) {
        s[i] = '\x00';
        i = i + 1;
    }
}

fn tomlString(table: *const toml.Table, key: []const u8) ?[]const u8 {
    const value = table.get(key) orelse return null;
    return switch (value) {
        .string => |s| s,
        else => null,
    };
}

fn tomlInteger(table: *const toml.Table, key: []const u8) ?i64 {
    const value = table.get(key) orelse return null;
    return switch (value) {
        .integer => |i| i,
        else => null,
    };
}

// parse the device info,
// device must have a watch topics
fn parseDevice(allocator: mem.Allocator, name: []const u8, entry: *const toml.Table) !*MonitoringInfo {
    const device = try MonitoringInfo.init(allocator);
    errdefer device.deinit();
    const allocName = try allocator.alloc(u8, name.len + 1);

    secureZero(allocName);

    @memcpy(allocName[0..name.len], name);
    device.name = allocName;

    if (tomlString(entry, "exec")) |execValue| {
        assert(execValue.len > 0);
        const execCommand = try allocator.allocSentinel(u8, execValue.len, 0);
        @memcpy(execCommand[0..execValue.len], execValue);
        const additionalStructure = try allocator.create(AdditionalProcessInformation);
        additionalStructure.exec = execCommand;
        additionalStructure.pid = null;
        additionalStructure.lastRestarted = 0;
        additionalStructure.restartedCount = 0;
        device.associatedProcessInformation = additionalStructure;
    }

    if (tomlString(entry, "watchTopics")) |watchValue| {
        // there may have a wildcard at the end
        // strip it to compare to the received topic
        assert(watchValue.len > 0);
        const strippedLastWildCard = try stripLastWildCard(watchValue);
        const stopic = try allocator.alloc(u8, strippedLastWildCard.len);
        @memcpy(stopic[0..strippedLastWildCard.len], strippedLastWildCard);
        device.watchTopics = stopic;
        if (Verbose) {
            _ = try out.print("add {s} to device {s} \n", .{ device.name, device.watchTopics });
        }
    } else {
        return error.DEVICE_MUST_HAVE_A_WATCH_TOPIC;
    }

    if (tomlString(entry, "stateTopics")) |watchValue| {
        // there may have a wildcard at the end
        // strip it to compare to the received topic
        assert(watchValue.len > 0);
        const strippedLastWildCard = try stripLastWildCard(watchValue);
        const stopic = try allocator.alloc(u8, strippedLastWildCard.len);
        @memcpy(stopic[0..strippedLastWildCard.len], strippedLastWildCard);
        device.stateTopics = stopic;
        if (Verbose) {
            _ = try out.print("add {s} to device {s} \n", .{ device.name, device.stateTopics });
        }
    }

    if (tomlString(entry, "helloTopic")) |helloValue| {
        assert(helloValue.len > 0);
        const stopic = try allocator.alloc(u8, helloValue.len);
        @memcpy(stopic[0..helloValue.len], helloValue);
        device.helloTopic = stopic;
        if (Verbose) {
            _ = try out.print("hello topic for device {s}\n", .{device.helloTopic});
        }
    }

    if (tomlInteger(entry, "watchTimeOut")) |timeOutValue| {
        device.timeoutValue = @intCast(timeOutValue);
        if (Verbose) {
            _ = try out.print("watch timeout for topic for device {s}\n", .{device.helloTopic});
        }
    }

    try device.updateNextContact();
    return device;
}

const Config = struct { clientId: []u8, mqttBroker: []u8, user: []u8, password: []u8, clientid: []u8, mqttIotmonitorBaseTopic: []u8 };
const HttpServerConfig = struct { activateHttp: bool = true, listenAddress: []u8, port: u16 = 8079 };

var MqttConfig: *Config = undefined;
var HttpConfig: *HttpServerConfig = undefined;

fn parseTomlConfig(io: std.Io, allocator: mem.Allocator, _alldevices: *AllDevices, filename: []const u8) !void {
    const t = tracy.trace(@src());
    defer t.end();

    var parser = toml.Parser(toml.Table).init(allocator);
    defer parser.deinit();

    var parsed = try parser.parseFile(io, filename);
    defer parsed.deinit();
    const config = &parsed.value;

    var it = config.iterator();
    while (it.next()) |e| {
        switch (e.value_ptr.*) {
            .table => |table| {
                const section = e.key_ptr.*;
                if (section.len < 7) continue;

                const DEVICEPREFIX = "device_";
                const AGENTPREFIX = "agent_";
                const isDevice = mem.eql(u8, section[0..DEVICEPREFIX.len], DEVICEPREFIX);
                const isAgent = mem.eql(u8, section[0..AGENTPREFIX.len], AGENTPREFIX);
                if (isDevice or isAgent) {
                    if (Verbose) {
                        try out.print("device found :{s}\n", .{section});
                    }
                    const prefixlen: usize = if (isDevice) DEVICEPREFIX.len else AGENTPREFIX.len;

                    const dev = try parseDevice(allocator, section[prefixlen..], table);
                    if (Verbose) {
                        try out.print("add {s} to device list, with watch {s} and state {s} \n", .{ dev.name, dev.watchTopics, dev.stateTopics orelse "(none)" });
                    }
                    _ = try _alldevices.put(dev.name, dev);
                } else if (!mem.eql(u8, section, "mqtt") and !mem.eql(u8, section, "http")) {
                    try out.print("bad prefix for section :{s} , only device_ or agent_ accepted, skipped \n", .{section});
                }
            },
            else => continue,
        }
    }

    const conf = try allocator.create(Config);

    const mqtt_value = config.get("mqtt") orelse return error.ConfigNoMqttSection;
    const mqttconfig = switch (mqtt_value) {
        .table => |table| table,
        else => return error.ConfigNoMqttSection,
    };

    if (tomlString(mqttconfig, "serverAddress")) |configAdd| {
        conf.mqttBroker = try allocator.dupe(u8, configAdd);
    } else {
        return error.noKeyServerAddress;
    }

    if (tomlString(mqttconfig, "user")) |u| {
        conf.user = try allocator.dupe(u8, u);
    } else {
        return error.ConfigNoUser;
    }

    if (tomlString(mqttconfig, "password")) |p| {
        conf.password = try allocator.dupe(u8, p);
    } else {
        return error.ConfigNoPassword;
    }

    if (tomlString(mqttconfig, "clientid")) |cid| {
        conf.clientid = try allocator.dupe(u8, cid);
        try out.print("Using {s} as clientid \n", .{conf.clientid});
    } else {
        conf.clientid = try allocator.dupe(u8, "iotmonitor");
    }

    const topicBase = tomlString(mqttconfig, "baseTopic") orelse "home/monitoring";
    conf.mqttIotmonitorBaseTopic = try allocator.alloc(u8, topicBase.len + 1);
    conf.mqttIotmonitorBaseTopic[topicBase.len] = 0;
    @memcpy(conf.mqttIotmonitorBaseTopic[0..topicBase.len], topicBase);

    const httpconf = try allocator.create(HttpServerConfig);
    httpconf.* = .{
        .activateHttp = false,
        .listenAddress = try allocator.dupe(u8, "127.0.0.1"),
        .port = 8079,
    };

    if (config.get("http")) |http_value| {
        switch (http_value) {
            .table => |http_table| {
                httpconf.activateHttp = true;

                if (tomlString(http_table, "bind")) |baddr| {
                    allocator.free(httpconf.listenAddress);
                    httpconf.listenAddress = try allocator.dupe(u8, baddr);
                }

                if (tomlInteger(http_table, "port")) |port| {
                    httpconf.port = @intCast(port);
                }
            },
            else => {},
        }
    }

    HttpConfig = httpconf;
    MqttConfig = conf;
}

// MQTT call back to handle the error handling and not
// send the error to C paho library
fn _external_callback(topic: []u8, message: []u8) void {
    callback(topic, message) catch {
        @panic("error in the callback");
    };
}

// MQTT Callback implementation
fn callback(topic: []u8, message: []u8) !void {
    const t = tracy.trace(@src());
    defer t.end();

    // MQTT callback
    if (Verbose) {
        try out.print("on topic {s}\n", .{topic});
        try out.print("  message arrived {s}\n", .{message});
        try out.writeAll(topic);
        try out.writeAll("\n");
    }

    // look for all devices
    var iterator = alldevices.iterator();

    // device loop
    while (iterator.next()) |e| {
        const deviceInfo = e.value_ptr.*;
        if (Verbose) {
            if (deviceInfo.stateTopics) |stopic| {
                try out.print("evaluate state topic {s} with incoming topic {s} \n", .{ stopic, topic });
            }
        }
        const watchTopic = deviceInfo.watchTopics;
        const storeTopic = deviceInfo.stateTopics;
        const helloTopic = deviceInfo.helloTopic;
        if (storeTopic) |store| {
            if (try topics.doesTopicBelongTo(topic, store)) |_| {

                // always store topic, even if the monitoring is not enabled

                // store sub topic in leveldb
                // trigger the refresh for timeout
                if (Verbose) {
                    try out.print("sub topic to store value :{s}, in {s}\n", .{ message, topic });
                    try out.print("length {}\n", .{topic.len});
                }
                db.put(topic, message) catch |errStorage| {
                    log.warn("fail to store message {s} for topic {s}, on database with error {} \n", .{ message, topic, errStorage });
                };
            }
        }
        if (helloTopic) |hello| {
            if (mem.eql(u8, topic, hello)) {
                if (Verbose) {
                    try out.print("device started, put all state informations \n", .{});
                }
                // count the number of hello topic
                //
                //
                deviceInfo.helloTopicCount += 1;

                // iterate on db, on state topic

                const itstorage = try db.iterator();
                // itstorage is an allocated pointer
                defer globalAllocator.destroy(itstorage);
                defer itstorage.deinit();
                itstorage.first();
                while (itstorage.isValid()) {
                    const storedTopic = itstorage.iterKey();
                    if (storedTopic) |storedTopicValue| {
                        defer globalAllocator.destroy(storedTopicValue);
                        if (storedTopicValue.len >= topic.len) {
                            const slice = storedTopicValue.*;
                            if (mem.eql(u8, slice[0..topic.len], topic[0..])) {
                                if (deviceInfo.enabled) {
                                    // send the state only if the monitoring is enabled

                                    const stateTopic = itstorage.iterValue();
                                    if (stateTopic) |stateTopicValue| {
                                        if (Verbose) {
                                            try out.print("sending state {s} to topic {s}\n", .{ stateTopic.?.*, slice });
                                        }
                                        defer globalAllocator.destroy(stateTopicValue);
                                        const topicWithSentinel = try globalAllocator.allocSentinel(u8, storedTopicValue.*.len, 0);
                                        defer globalAllocator.free(topicWithSentinel);
                                        @memcpy(topicWithSentinel[0..storedTopicValue.*.len], storedTopicValue.*);

                                        // resend state
                                        cnx.publish(topicWithSentinel, stateTopicValue.*) catch |errorMqtt| {
                                            log.warn("ERROR {} fail to publish initial state on topic {}", .{ errorMqtt, topicWithSentinel });
                                            try out.print(".. state restoring done, listening mqtt topics\n", .{});
                                        };
                                    }
                                }
                            }
                        }
                    }
                    itstorage.next();
                }
            }
        } // hello
        if (try topics.doesTopicBelongTo(topic, watchTopic)) |_| {
            // trigger the timeout for the iot element
            try deviceInfo.updateNextContact();
        }
    }

    if (Verbose) {
        try out.print("end of callback \n", .{});
    }
}

// global types
const AllDevices = std.StringHashMap(*MonitoringInfo);
const DiskHash = leveldb.LevelDBHashArray(u8, u8);

// global variables
var globalAllocator: mem.Allocator = undefined;
var alldevices: AllDevices = undefined;
var db: *DiskHash = undefined;

test "read whole database" {
    db = try DiskHash.init(globalAllocator);
    const filename = "iotdb.leveldb";
    _ = try db.open(filename);
    defer db.close();

    const iterator = try db.iterator();
    defer globalAllocator.destroy(iterator);
    defer iterator.deinit();
    log.warn("Dump the iot database \n", .{});
    iterator.first();
    while (iterator.isValid()) {
        const optReadKey = iterator.iterKey();
        if (optReadKey) |k| {
            defer globalAllocator.destroy(k);
            const optReadValue = iterator.iterValue();
            if (optReadValue) |v| {
                log.warn("   key :{} value: {}\n", .{ k.*, v.* });
                defer globalAllocator.destroy(v);
            }
        }
        iterator.next();
    }
}
// main connection for subscription
var cnx: *mqtt.MqttCnx = undefined;
var cpt: u32 = 0;

const MAGICPROCSSHEADER = "IOTMONITORMAGIC_";
const MAGIC_BUFFER_SIZE = 16 * 1024;
const LAUNCH_COMMAND_LINE_BUFFER_SIZE = 16 * 1024;

fn launchProcess(monitoringInfo: *MonitoringInfo) !void {
    assert(monitoringInfo.associatedProcessInformation != null);
    const associatedProcessInformation = monitoringInfo.*.associatedProcessInformation.?.*;
    const pid = c.fork();
    if (pid == 0) {
        // detach from parent, this permit the process to live independently from
        // its parent
        _ = c.setsid();

        const bufferMagic = globalAllocator.allocSentinel(u8, MAGIC_BUFFER_SIZE, 0) catch unreachable;
        defer globalAllocator.free(bufferMagic);
        _ = c.sprintf(bufferMagic.ptr, "%s%s", MAGICPROCSSHEADER, monitoringInfo.name.ptr);

        const commandLineBuffer = globalAllocator.allocSentinel(u8, LAUNCH_COMMAND_LINE_BUFFER_SIZE, 0) catch unreachable;
        defer globalAllocator.free(commandLineBuffer);

        const exec = associatedProcessInformation.exec;
        _ = c.sprintf(commandLineBuffer.ptr, "echo %s;%s;echo END", bufferMagic.ptr, exec.ptr);

        _ = c.setenv("IOTMONITORMAGIC", bufferMagic.ptr, 1);
        _ = c.execl("/bin/bash", "bash", "-c", commandLineBuffer.ptr, @as(?[*:0]const u8, null));
        unreachable;
    } else if (pid > 0) {
        try out.print("process launched, pid : {}\n", .{pid});
        monitoringInfo.*.associatedProcessInformation.?.pid = pid;
        monitoringInfo.*.associatedProcessInformation.?.restartedCount += 1;
        _ = c.time(&monitoringInfo.*.associatedProcessInformation.?.lastRestarted);

        // launch mqtt restart information process in monitoring
        try publishProcessStarted(monitoringInfo);
    }
}

test "test_launch_process" {
    globalAllocator = std.heap.c_allocator;
    alldevices = AllDevices.init(globalAllocator);

    var processInfo = AdditionalProcessInformation{
        .exec = "sleep 20",
        .pid = undefined,
    };
    var d = MonitoringInfo{
        .timeoutValue = 1,
        .name = "MYPROCESS",
        .watchTopics = "",
        .nextContact = undefined,
        .allocator = undefined,
        .helloTopic = undefined,
        .stateTopics = undefined,
        .associatedProcessInformation = &processInfo,
    };

    // try launchProcess(&d);
    // const pid: i32 = d.associatedProcessInformation.?.*.pid.?;
    // debug.warn("pid launched : {}\n", .{pid});

    try alldevices.put(d.name, &d);

    // var p: processlib.ProcessInformation = .{};
    // const processFound = try processlib.getProcessInformations(pid, &p);
    // assert(processFound);

    try processlib.listProcesses(handleCheckAgent);
}

fn handleCheckAgent(processInformation: *processlib.ProcessInformation) void {
    // iterate over the devices, to check which device belong to this process
    // information
    var it = alldevices.iterator();

    while (it.next()) |deviceInfo| {
        const device = deviceInfo.value_ptr.*;
        // not on optional
        if (device.associatedProcessInformation) |infos| {
            // check if process has the magic Key in the process list
            var itCmdLine = processInformation.iterator();
            while (itCmdLine.next()) |a| {
                if (Verbose) {
                    out.print("look in {s}\n", .{a}) catch unreachable;
                }

                const bufferMagic = globalAllocator.allocSentinel(u8, MAGIC_BUFFER_SIZE, 0) catch unreachable;
                defer globalAllocator.free(bufferMagic);
                _ = c.sprintf(bufferMagic.ptr, "%s%s", MAGICPROCSSHEADER, device.name.ptr);

                const p = c.strstr(a.ptr, bufferMagic.ptr);
                if (Verbose) {
                    out.print("found {*}\n", .{p}) catch unreachable;
                }
                if (p != null) {
                    // found in arguments, remember the pid
                    // of the process
                    infos.*.pid = processInformation.*.pid;
                    if (Verbose) {
                        out.print("process {} is monitored pid found\n", .{infos.pid}) catch unreachable;
                    }
                    break;
                }
                if (Verbose) {
                    out.writeAll("next ..\n") catch unreachable;
                }
            }
        } else {
            continue;
        }
    }
}

fn runAllMissings() !void {
    // once all the process have been browsed,
    // run all missing processes

    var it = alldevices.iterator();
    while (it.next()) |deviceinfo| {
        const device = deviceinfo.value_ptr.*;
        if (device.associatedProcessInformation) |processinfo| {
            // this is a process monitored
            if (device.enabled) {
                if (processinfo.*.pid == null) {
                    out.print("running ...{s} \n", .{device.name}) catch unreachable;
                    // no pid associated to the info
                    //
                    launchProcess(device) catch {
                        @panic("fail to run process");
                    };
                }
            } else {
                // monitoring not enabled on the process

            }
        }
    }
}

fn checkProcessesAndRunMissing() !void {
    const t = tracy.trace(@src());
    defer t.end();

    // RAZ pid infos
    var it = alldevices.iterator();

    while (it.next()) |deviceInfo| {
        const device = deviceInfo.value_ptr.*;
        if (device.associatedProcessInformation) |infos| {
            infos.pid = null;
        }
    }
    // list all process for wrapping
    try processlib.listProcesses(handleCheckAgent);
    try runAllMissings();
}

// this function publish a watchdog for the iotmonitor process
// this permit to check if the monitoring is up
fn publishWatchDog() !void {
    const t = tracy.trace(@src());
    defer t.end();

    const topicBufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(topicBufferPayload);
    secureZero(topicBufferPayload);
    _ = c.sprintf(topicBufferPayload.ptr, "%s/up", MqttConfig.mqttIotmonitorBaseTopic.ptr);

    var bufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(bufferPayload);
    secureZero(bufferPayload);
    cpt = (cpt + 1) % 1_000_000;
    _ = c.sprintf(bufferPayload.ptr, "%d", cpt);

    const payloadLength = c.strlen(bufferPayload.ptr);

    cnx.publish(topicBufferPayload.ptr, bufferPayload[0..payloadLength]) catch {
        log.warn("cannot publish watchdog message, will retryi \n", .{});
    };
}

fn publishProcessStarted(mi: *MonitoringInfo) !void {
    const t = tracy.trace(@src());
    defer t.end();

    const topicBufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(topicBufferPayload);
    secureZero(topicBufferPayload);
    _ = c.sprintf(topicBufferPayload.ptr, "%s/startedprocess/%s", MqttConfig.mqttIotmonitorBaseTopic.ptr, mi.name.ptr);

    var bufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(bufferPayload);
    secureZero(bufferPayload);
    _ = c.sprintf(bufferPayload.ptr, "%d", mi.*.associatedProcessInformation.?.lastRestarted);

    const payloadLength = c.strlen(bufferPayload.ptr);
    cnx.publish(topicBufferPayload.ptr, bufferPayload[0..payloadLength]) catch {
        log.warn("cannot publish watchdog message, will retryi \n", .{});
    };
}

// this publish on the mqtt broker the process informations
//
fn publishDeviceMonitoringInfos(device: *MonitoringInfo) !void {
    const topicBufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(topicBufferPayload);
    secureZero(topicBufferPayload);
    _ = c.sprintf(topicBufferPayload.ptr, "%s/helloTopicCount/%s", MqttConfig.mqttIotmonitorBaseTopic.ptr, device.*.name.ptr);

    var bufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(bufferPayload);
    secureZero(bufferPayload);

    _ = c.sprintf(bufferPayload.ptr, "%u", device.helloTopicCount);
    const payloadLen = c.strlen(bufferPayload.ptr);

    cnx.publish(topicBufferPayload.ptr, bufferPayload[0..payloadLen]) catch {
        log.warn("cannot publish timeout message for device {} , will retry \n", .{device.name});
    };
}

// this function pulish a mqtt message for a device that is not publishing
// it mqtt messages
fn publishDeviceTimeOut(device: *MonitoringInfo) !void {
    const topicBufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(topicBufferPayload);
    secureZero(topicBufferPayload);
    _ = c.sprintf(topicBufferPayload.ptr, "%s/expired/%s", MqttConfig.mqttIotmonitorBaseTopic.ptr, device.*.name.ptr);

    var bufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(bufferPayload);

    secureZero(bufferPayload);
    _ = c.sprintf(bufferPayload.ptr, "%d", device.nextContact);
    const payloadLen = c.strlen(bufferPayload.ptr);

    cnx.publish(topicBufferPayload.ptr, bufferPayload[0..payloadLen]) catch {
        log.warn("cannot publish timeout message for device {} , will retry \n", .{device.name});
    };
}

const JSONStatus = struct {
    name: []const u8,
    enabled: bool = true,
    expired: bool,
};

fn statusJsonHandler(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    _ = path;
    const t = tracy.trace(@src());
    defer t.end();

    var aw: std.Io.Writer.Allocating = .init(allocator);
    errdefer aw.deinit();
    try aw.writer.writeAll("[");
    var hasone = false;
    var iterator = alldevices.iterator();
    while (iterator.next()) |e| {
        const deviceInfo = e.value_ptr.*;
        if (hasone) {
            try aw.writer.writeAll(",");
        }
        const j = JSONStatus{
            .name = deviceInfo.name[0 .. deviceInfo.name.len - 1],
            .enabled = deviceInfo.enabled,
            .expired = try deviceInfo.hasExpired(),
        };
        try json.Stringify.value(j, .{}, &aw.writer);
        hasone = true;
    }
    try aw.writer.writeAll("]");
    return try aw.toOwnedSlice();
}

const HttpServerCtx = struct { io: std.Io, addr: []const u8, port: u16 };

fn startHttpServer(ctx: HttpServerCtx) void {
    httpserver.listenAndServe(ctx.io, ctx.addr, ctx.port, globalAllocator, statusJsonHandler) catch {
        @panic("cannot start listening http server");
    };
}

// main procedure
pub fn main(init: std.process.Init) !void {
    globalAllocator = init.gpa;
    out_file_writer = std.Io.File.stdout().writerStreaming(init.io, &out_buffer);
    out = &out_file_writer.interface;

    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help
        \\-v, --version          Display version
        \\<TOML_CONFIG_FILE>...
        \\
    );

    var diag = clap.Diagnostic{};

    const parsers = comptime .{
        .TOML_CONFIG_FILE = clap.parsers.string,
    };

    var res = clap.parse(clap.Help, &params, parsers, init.minimal.args, .{
        .diagnostic = &diag,
        .allocator = init.gpa,
    }) catch |err| {
        try diag.reportToFile(init.io, .stderr(), err);
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) {
        debug.print("\n", .{});
        debug.print("start the iotmonitor deamon, usage :\n", .{});
        debug.print("    iotmonitor [optional config.toml filepath]\n", .{});
        debug.print("\n", .{});
        return;
    }

    if (res.args.version != 0) {
        debug.print("{s}", .{version.version});
        return;
    }

    try out.writeAll("IotMonitor start, version ");
    try out.writeAll(version.version);
    try out.writeAll("\n");

    // default
    const defaultConfigFile = "config.toml";
    var configurationFile = try globalAllocator.alloc(u8, defaultConfigFile.len);
    @memcpy(configurationFile[0..defaultConfigFile.len], defaultConfigFile);
    var arg_index: u32 = 0;
    for (res.positionals[0]) |pos| {
        debug.print("{s}\n", .{pos});
        debug.print("{}\n", .{pos.len});
        if (arg_index == 0) {
            globalAllocator.free(configurationFile);
            configurationFile = try globalAllocator.alloc(u8, pos.len);
            @memcpy(configurationFile[0..pos.len], pos);
        }
        arg_index += 1;
    }

    try out.writeAll("Reading ");
    try out.writeAll(configurationFile);
    try out.writeAll(" file\n");

    // Friendly error if the file does not exists
    var f = std.Io.Dir.cwd().openFile(init.io, configurationFile, .{}) catch {
        try out.writeAll("Cannot open file ");
        try out.writeAll(configurationFile);
        try out.writeAll("\n");
        return;
    };
    f.close(init.io);

    alldevices = AllDevices.init(globalAllocator);
    try parseTomlConfig(init.io, globalAllocator, &alldevices, configurationFile);

    try out.writeAll("Opening database\n");

    db = try DiskHash.init(globalAllocator);
    const filename = "iotdb.leveldb";
    _ = try db.open(filename);
    defer db.close();

    // connecting to MQTT

    const serverAddress: []const u8 = MqttConfig.mqttBroker;
    const userName: []const u8 = MqttConfig.user;
    const password: []const u8 = MqttConfig.password;
    const clientid: []const u8 = MqttConfig.clientid;

    try out.writeAll("Connecting to mqtt ..\n");

    try out.print("    connecting to \"{s}\" with user \"{s}\" and clientid \"{s}\"\n", .{ serverAddress, userName, clientid });

    cnx = try mqtt.MqttCnx.init(globalAllocator, serverAddress, clientid, userName, password);

    if (HttpConfig.activateHttp) {
        try out.print("Start embedded http server on port {} \n", .{HttpConfig.port});
        const threadHandle = try std.Thread.spawn(.{}, startHttpServer, .{HttpServerCtx{
            .io = init.io,
            .addr = HttpConfig.listenAddress,
            .port = HttpConfig.port,
        }});
        _ = threadHandle;
        try out.print("Http server thread launched\n", .{});
    }

    try out.print("Checking running monitored processes\n", .{});
    try checkProcessesAndRunMissing();

    try out.print("Restoring saved states topics ... \n", .{});
    // read all elements in database, then redefine the state for all
    const it = try db.iterator();
    defer globalAllocator.destroy(it);
    defer it.deinit();

    it.first();
    while (it.isValid()) {
        const r = it.iterKey();
        if (r) |subject| {
            defer globalAllocator.destroy(subject);
            const v = it.iterValue();
            if (v) |value| {
                defer globalAllocator.destroy(value);
                try out.print("Sending initial stored state {s} to {s}\n", .{ value.*, subject.* });

                const topicWithSentinel = try globalAllocator.allocSentinel(u8, subject.*.len, 0);
                defer globalAllocator.free(topicWithSentinel);
                @memcpy(topicWithSentinel[0..subject.*.len], subject.*);

                // if failed, stop the process
                cnx.publish(topicWithSentinel, value.*) catch |e| {
                    log.warn("ERROR {} fail to publish initial state on topic {s}", .{ e, topicWithSentinel });
                    try out.print(".. State restoring done, listening mqtt topics\n", .{});
                };
            }
        }
        it.next();
    }
    try out.print(".. State restoring done, listening mqtt topics\n", .{});
    cnx.callBack = _external_callback;

    // register to all, it may be huge, and probably not scaling
    _ = try cnx.register("#");

    while (true) { // main loop
        _ = c.sleep(1); // every 1 seconds

        {
            // if activated trace this function
            const t = tracy.trace(@src());
            defer t.end();

            // check process that has falled down, and must be restarted
            try checkProcessesAndRunMissing();
            // watchdog
            try publishWatchDog();

            var iterator = alldevices.iterator();
            while (iterator.next()) |e| {
                // publish message
                const deviceInfo = e.value_ptr.*;

                if (deviceInfo.enabled) {
                    // if the device is enabled
                    const hasExpired = try deviceInfo.hasExpired();
                    if (hasExpired) {
                        try publishDeviceTimeOut(deviceInfo);
                    }
                    try publishDeviceMonitoringInfos(deviceInfo);
                }
            }
        }
    }

    log.warn("ended", .{});
    return;
}
