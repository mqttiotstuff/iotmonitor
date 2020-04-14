//
//  IOT Monitor - monitor and recover state for iot device and software agents
//
//  pfreydiere - 2019 - 2020
//

const std = @import("std");
const debug = std.debug;
const assert = debug.assert;
const mem = std.mem;

const leveldb = @import("leveldb.zig");
const mqtt = @import("mqttlib.zig");

// used for sleep, and other, it may be removed
// to relax libC needs
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("unistd.h");
    @cInclude("time.h");
    @cInclude("string.h");
});

const toml = @import("toml");

const out = std.io.getStdOut().outStream();

const Verbose = false;

// test if the evaluted topic belong to the reference Topic,
// return the sub path if it is
fn doesTopicBelongTo(evaluatedTopic: []const u8, referenceTopic: []const u8) !?[]const u8 {
    if (evaluatedTopic.len < referenceTopic.len) return null;
    const isWatched = mem.eql(u8, evaluatedTopic[0..referenceTopic.len], referenceTopic);
    if (isWatched) {
        const subTopic = evaluatedTopic[referenceTopic.len..];
        return subTopic;
    }
    return null;
}

test "Test belong to" {
    const topic1: []const u8 = "/home";
    const topic2: []const u8 = "/home";
    const a = try doesTopicBelongTo(topic1, topic2);
    assert(a != null);
    assert(a.?.len == 0);
}
test "sub path" {
    const topic1: []const u8 = "/home";
    const topic2: []const u8 = "/ho";
    const a = try doesTopicBelongTo(topic1, topic2);
    assert(a != null);
    assert(a.?.len == 2);
    assert(mem.eql(u8, a.?, "me"));
}
test "no match 1" {
    const topic1: []const u8 = "/home";
    const topic2: []const u8 = "/ho2";
    const a = try doesTopicBelongTo(topic1, topic2);
    assert(a == null);
}
test "no match 2" {
    const topic1: []const u8 = "/home";
    const topic2: []const u8 = "/home2";
    const a = try doesTopicBelongTo(topic1, topic2);
    assert(a == null);
}

const DeviceInfo = struct {
    name: []const u8 = "",
    watchTopics: []const u8,
    nextContact: c.time_t,
    timeoutValue: u32 = 30,
    stateTopics: ?[]const u8,
    helloTopic: ?[]const u8,
    allocator: *mem.Allocator,
    fn init(allocator: *mem.Allocator) !*DeviceInfo {
        const device = try allocator.create(DeviceInfo);
        device.allocator = allocator;
        return device;
    }
    fn deinit(self: *DeviceInfo) void {
        self.allocator.destroy(self);
    }

    fn updateNextContact(device: *DeviceInfo) !void {
        _ = c.time(&device.*.nextContact);
        device.*.nextContact = device.*.nextContact + @intCast(c_long, device.*.timeoutValue);
    }

    fn hasExpired(device: *DeviceInfo) !bool {
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
        // try out.writeAll("remove the topic prefix \n");
        return watchValue[0 .. watchValue.len - 2];
    }
    return watchValue;
}
test "test update time" {
    var d = DeviceInfo{
        .timeoutValue = 1,
        .watchTopics = "",
        .nextContact = undefined,
        .allocator = undefined,
        .helloTopic = undefined,
        .stateTopics = undefined,
    };
    try d.updateNextContact();
    _ = c.sleep(3);
    std.debug.assert(try d.hasExpired());

    d.timeoutValue = 20;
    try d.updateNextContact();

    _ = c.sleep(3);
    std.debug.assert(!try d.hasExpired());
}

// parse the device info,
// device must have a watch topics
fn parseDevice(allocator: *mem.Allocator, name: *[]const u8, entry: *toml.Table) !*DeviceInfo {
    const device = try DeviceInfo.init(allocator);
    errdefer device.deinit();
    const allocName = try allocator.alloc(u8, name.*.len + 1);
    mem.secureZero(u8, allocName);
    std.mem.copy(u8, allocName, name.*);
    device.name = allocName;

    if (entry.getKey("watchTopics")) |watch| {
        // there may have a wildcard at the end
        // strip it to compare to the received topic
        const watchValue = watch.String;
        assert(watchValue.len > 0);
        device.watchTopics = try stripLastWildCard(watchValue);
        if (Verbose) {
            _ = try out.print("add {} to device {} \n", .{ device.name, device.watchTopics });
        }
    } else {
        return error.DEVICE_MUST_HAVE_A_WATCH_TOPIC;
    }

    if (entry.getKey("stateTopics")) |watch| {
        // there may have a wildcard at the end
        // strip it to compare to the received topic
        const watchValue = watch.String;
        assert(watchValue.len > 0);
        device.stateTopics = try stripLastWildCard(watchValue);
        if (Verbose) {
            _ = try out.print("add {} to device {} \n", .{ device.name, device.stateTopics });
        }
    }

    if (entry.getKey("helloTopic")) |hello| {
        const helloValue = hello.String;
        assert(helloValue.len > 0);
        device.helloTopic = helloValue;
        if (Verbose) {
            _ = try out.print("hello topic for device {}\n", .{device.helloTopic});
        }
    }

    if (entry.getKey("watchTimeOut")) |timeout| {
        const timeOutValue = timeout.Integer;
        device.timeoutValue = @intCast(u32, timeOutValue);
        if (Verbose) {
            _ = try out.print("watch timeout for topic for device {}\n", .{device.helloTopic});
        }
    }

    try device.updateNextContact();
    return device;
}

const Config = struct {
    clientId: []const u8,
    mqttBroker: []const u8,
    user: []const u8,
    password: []const u8,
    mqttIotmonitorBaseTopic: [] u8
};

var MqttConfig: *Config = undefined;

fn parseTomlConfig(allocator: *mem.Allocator, _alldevices: *AllDevices, filename: []const u8) !void {
    // getting config parameters
    var config = try toml.parseFile(allocator, filename);
    defer config.deinit();

    var it = config.children.iterator();
    while (it.next()) |e| {
        if (e.key.len >= 7) {
            const isEqual = mem.eql(u8, e.key[0..7], "device_");
            if (isEqual) {
                if (Verbose) {
                    try out.print("device found :{}\n", .{e.key});
                }
                const dev = try parseDevice(allocator, &e.key[7..], e.value);
                if (Verbose) {
                    try out.print("add {} to device list, with watch {} and state {} \n", .{ dev.name, dev.watchTopics, dev.stateTopics });
                }
                _ = try _alldevices.put(dev.name, dev);
            }
        }
    }

    const conf = try allocator.create(Config);

    if (config.getTable("mqtt")) |mqttconfig| {
        if (mqttconfig.getKey("serverAddress")) |configAdd| {
            conf.mqttBroker = configAdd.String;
        } else {
            return error.noKeyServerAddress;
        }

        if (mqttconfig.getKey("user")) |u| {
            conf.user = u.String;
        } else {
            return error.ConfigNoUser;
        }

        if (mqttconfig.getKey("password")) |p| {
            conf.password = p.String;
        } else {
            return error.ConfigNoPassword;
        }

        const topicBase = if (mqttconfig.getKey("baseTopic")) |baseTopic| baseTopic.String else 
            "home/monitoring";

        conf.mqttIotmonitorBaseTopic = try allocator.alloc(u8, topicBase.len + 1);
        conf.mqttIotmonitorBaseTopic[topicBase.len] = 0;
        mem.copy(u8,conf.mqttIotmonitorBaseTopic, topicBase[0..topicBase.len]);

    } else {
        return error.ConfignoMqtt;
    }

    MqttConfig = conf;
}

fn _external_callback(topic: []u8, message: []u8) void {
    callback(topic, message) catch {
        @panic("error in the callback");
    };
}

// implementation that return an error
fn callback(topic: []u8, message: []u8) !void {

    // MQTT callback
    if (Verbose) {
        try out.print("on topic {}\n", .{topic});
        try out.print("  message arrived {}\n", .{message});
        try out.writeAll(topic);
        try out.writeAll("\n");
    }

    // look for all devices
    var iterator = alldevices.iterator();
    while (iterator.next()) |e| {
        const deviceInfo = e.value;
        if (Verbose) {
            try out.print("evaluate {} with {} \n", .{ deviceInfo.stateTopics, topic });
        }
        const watchTopic = deviceInfo.watchTopics;
        const storeTopic = deviceInfo.stateTopics;
        const helloTopic = deviceInfo.helloTopic;
        if (storeTopic) |store| {
            if (try doesTopicBelongTo(topic, store)) |sub| {
                // store sub topic in leveldb
                // trigger the refresh for timeout
                if (Verbose) {
                    try out.print("sub topic to store value :{}, in {}\n", .{ message, topic });
                    try out.print("length {}\n", .{topic.len});
                }
                try db.put(topic, message);
            }
        }
        if (helloTopic) |hello| {
            if (mem.eql(u8, topic, hello)) {
                if (Verbose) {
                    try out.print("device started, put all state informations \n", .{});
                }
                // iterate on db, on state topic

                const itstorage = try db.iterator();
                itstorage.first();
                while (itstorage.isValid()) {
                    var storedTopic = itstorage.iterKey();
                    if (storedTopic) |storedTopicValue| {
                        if (storedTopicValue.len >= topic.len) {
                            const slice = storedTopicValue.*;
                            if (mem.eql(u8, slice[0..topic.len], topic[0..])) {
                                var stateTopic = itstorage.iterValue();
                                // try out.print("sending state {} to topic {}\n", .{ stateTopic.?.*, slice });
                                const topicWithSentinel = try globalAllocator.allocSentinel(u8, storedTopicValue.*.len, 0);
                                defer globalAllocator.free(topicWithSentinel);
                                mem.copy(u8, topicWithSentinel[0..], storedTopicValue.*);

                                // resend state
                                try cnx.publish(topicWithSentinel, stateTopic.?.*);
                            }
                        }
                    }
                    itstorage.next();
                }
            }
        }
        if (try doesTopicBelongTo(topic, watchTopic)) |sub| {
            // trigger the timeout for the iot element
            try deviceInfo.updateNextContact();
        }
    }

    if (Verbose) {
        try out.print("end of callback \n", .{});
    }
}

const AllDevices = std.StringHashMap(*DeviceInfo);

var alldevices: AllDevices = undefined;
const DiskHash = leveldb.LevelDBHashArray(u8, u8);
var db: *DiskHash = undefined;

var globalAllocator: *mem.Allocator = undefined;

test "read whole database" {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    globalAllocator = &arena.allocator;

    db = try DiskHash.init(globalAllocator);
    const filename = "iotdb.leveldb";
    _ = try db.open(filename);
    defer db.close();

    const iterator = try db.iterator();
    defer iterator.deinit();
    debug.warn("Dump the iot database \n", .{});
    iterator.first();
    while (iterator.isValid()) {
        const optReadKey = iterator.iterKey();
        if (optReadKey) |k| {
            const optReadValue = iterator.iterValue();
            if (optReadValue) |v| {
                debug.warn("   key :{} value: {}\n", .{ k.*, v.* });
            }
        }
        iterator.next();
    }
}
// main connection for subscription
var cnx: *mqtt.MqttCnx = undefined;

var cpt: u32 = 0;

fn publishWatchDog() !void {

    var topicBufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(topicBufferPayload);
    mem.secureZero(u8, topicBufferPayload);
    _ = c.sprintf(topicBufferPayload.ptr, "%s/up", MqttConfig.mqttIotmonitorBaseTopic.ptr);

    var bufferPayload = try globalAllocator.alloc(u8, 512);
    mem.secureZero(u8, bufferPayload);
    cpt = (cpt + 1) % 1_000_000;
    _ = c.sprintf(bufferPayload.ptr, "%d", cpt);
    const topicloadLength = c.strlen(topicBufferPayload.ptr);
    const payloadLength = c.strlen(bufferPayload.ptr);
    try cnx.publish(topicBufferPayload.ptr, bufferPayload[0..payloadLength]);
    globalAllocator.free(bufferPayload);
}

fn publishDeviceTimeOut(device: *DeviceInfo) !void {

    var topicBufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(topicBufferPayload);
    mem.secureZero(u8, topicBufferPayload);
    _ = c.sprintf(topicBufferPayload.ptr, "%s/expired/%s", MqttConfig.mqttIotmonitorBaseTopic.ptr, device.*.name.ptr);

    var bufferPayload = try globalAllocator.alloc(u8, 512);
    defer globalAllocator.free(bufferPayload);

    mem.secureZero(u8, bufferPayload);
    _ = c.sprintf(bufferPayload.ptr, "%d", device.nextContact);
    const payloadLen = c.strlen(bufferPayload.ptr);

    try cnx.publish(topicBufferPayload.ptr, bufferPayload[0..payloadLen]);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    globalAllocator = &arena.allocator;

    alldevices = AllDevices.init(globalAllocator);

    const configurationFile = "config.toml";
    try out.writeAll("Reading the config file\n");

    try parseTomlConfig(globalAllocator, &alldevices, configurationFile);

    try out.writeAll("Opening database\n");

    db = try DiskHash.init(globalAllocator);
    const filename = "iotdb.leveldb";
    _ = try db.open(filename);
    defer db.close();

    // connecting to MQTT

    var serverAddress: []const u8 = MqttConfig.mqttBroker;
    var userName: []const u8 = MqttConfig.user;
    var password: []const u8 = MqttConfig.password;

    var clientid: []const u8 = "clientid_iotmonitor";

    try out.writeAll("Connecting to mqtt ..\n");

    try out.print("connecting to {} with user {}\n", .{ serverAddress, userName });

    cnx = try mqtt.MqttCnx.init(globalAllocator, serverAddress, clientid, userName, password);

    // read all elements in database, then redefine the state for all
    const it = try db.iterator();
    defer it.deinit();

    it.first();
    while (it.isValid()) {
        const r = it.iterKey();
        if (r) |subject| {
            defer globalAllocator.destroy(subject);
            const v = it.iterValue();
            if (v) |value| {
                defer globalAllocator.destroy(value);
                try out.print("sending initial stored state {} to {}\n", .{ value.*, subject.* });

                const topicWithSentinel = try globalAllocator.allocSentinel(u8, subject.*.len, 0);
                defer globalAllocator.free(topicWithSentinel);
                mem.copy(u8, topicWithSentinel[0..], subject.*);

                try cnx.publish(topicWithSentinel, value.*);
            }
        }
        it.next();
    }

    cnx.callBack = _external_callback;

    // register to all, it may be huge,
    // but C/Zig handle it for small hubs
    _ = try cnx.register("#");

    while (true) {
        _ = c.sleep(1); // in seconds
        try publishWatchDog();

        var iterator = alldevices.iterator();
        while (iterator.next()) |e| {
            const deviceInfo = e.value;
            if (try deviceInfo.hasExpired()) {
                // publish message
                try publishDeviceTimeOut(deviceInfo);
            }
        }
    }

    debug.warn("ended", .{});

    return;
}
