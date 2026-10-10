const std = @import("std");
const mem = std.mem;
const debug = std.debug;
const log = std.log;

//const cmqtt = @import("mqtt_paho.zig");
const cmqtt = @cImport({
    @cInclude("MQTTClient.h");
});
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("unistd.h");
    @cInclude("string.h");
    @cInclude("time.h");
    //@cInclude("paho.mqtt.c/src/MQTTClient.h");
});

const CallBack = *const fn (topic: []u8, message: []u8) void;

const MAX_REGISTERED_TOPICS = 10;

const mqttlibError = error{FailToRegister};

// Connexion to mqtt
//
pub const MqttCnx = struct {
    const Self = @This();

    allocator: mem.Allocator,
    handle: cmqtt.MQTTClient = undefined,
    callBack: CallBack = undefined,
    latestDeliveryToken: *cmqtt.MQTTClient_deliveryToken = undefined,
    connected: bool = undefined,
    connect_option: *cmqtt.MQTTClient_connectOptions = undefined,

    reconnect_registered_topics_length: u16 = 0,
    reconnect_registered_topics: [10]?[]u8,

    // this message is received in an other thread
    fn _defaultCallback(topic: []u8, message: []u8) void {
        _ = c.printf("%s -> %s\n", topic.ptr, message.ptr);
    }

    fn _connLost(ctx: ?*anyopaque, m: [*c]u8) callconv(.c) void {
        _ = m;
        const self_ctx = @as(*Self, @ptrFromInt(@intFromPtr(ctx)));
        _ = c.printf("connection lost %d\n", self_ctx);
    }

    fn _msgArrived(ctx: ?*anyopaque, topic: [*c]u8, topic_length: c_int, message: [*c]cmqtt.MQTTClient_message) callconv(.c) c_int {
        _ = topic_length;

        const messagePtrAddress = @intFromPtr(&message);
        const cmsg = @as([*c][*c]cmqtt.MQTTClient_message, @ptrFromInt(messagePtrAddress));
        defer cmqtt.MQTTClient_freeMessage(cmsg);
        defer cmqtt.MQTTClient_free(topic);

        // unsafe conversion
        const self_ctx = @as(*Self, @ptrFromInt(@intFromPtr(ctx)));

        // paho always return a 0 in topic_length, we must then compute it
        // _ = c.printf("topic length is %d \n", topic_length);

        const tlength: usize = c.strlen(topic);
        // topic_length always 0 ... non sense
        const mlength: u32 = @intCast(message.*.payloadlen);

        const am = @intFromPtr(message.*.payload);
        const mptr = @as([*]u8, @ptrFromInt(am));
        // pass to zig in proper way with slices
        self_ctx.callBack(topic[0..tlength], mptr[0..mlength]);

        return 1; // properly handled
    }

    fn _delivered(ctx: ?*anyopaque, token: cmqtt.MQTTClient_deliveryToken) callconv(.c) void {
        // _ = c.printf("%s", "received token");
        // unsafe conversion
        const self_ctx = @as(*Self, @ptrFromInt(@intFromPtr(ctx)));
        self_ctx.*.latestDeliveryToken.* = token;
    }

    pub fn deinit(self: *Self) !void {
        _ = self;
    }

    pub fn init(allocator: mem.Allocator, serverAddress: []const u8, clientid: []const u8, username: []const u8, password: []const u8) !*Self {
        var handle: cmqtt.MQTTClient = undefined;

        // we need to make a safe string with zero ending
        const zServerAddress = try allocator.alloc(u8, serverAddress.len + 1);
        // defer allocator.free(zServerAddress);
        @memcpy(zServerAddress[0..serverAddress.len], serverAddress);
        zServerAddress[serverAddress.len] = '\x00';

        const zusername = try allocator.alloc(u8, username.len + 1);
        // defer allocator.free(zusername);
        @memcpy(zusername[0..username.len], username);
        zusername[username.len] = '\x00';

        const zpassword = try allocator.alloc(u8, password.len + 1);
        // defer allocator.free(zpassword);
        @memcpy(zpassword[0..password.len], password);
        zpassword[password.len] = '\x00';

        const zclientid = try allocator.alloc(u8, clientid.len + 1);
        // defer allocator.free(zclientid);
        @memcpy(zclientid[0..clientid.len], clientid);
        zclientid[clientid.len] = '\x00';

        // convert to C the input parameters (ensuring the sentinel)
        const MQTTCLIENT_PERSISTENCE_NONE = 1;
        const result = cmqtt.MQTTClient_create(&handle, zServerAddress.ptr, zclientid.ptr, MQTTCLIENT_PERSISTENCE_NONE, null);

        if (result > 0) return error.MQTTCreateError;
        const HEADER = [_]u8{ 'M', 'Q', 'T', 'C' };

        // we setup the struct here, because the initializer is a macro in C,
        var conn_options = cmqtt.MQTTClient_connectOptions{
            .struct_id = HEADER,
            .struct_version = 0,
            .keepAliveInterval = 60,
            .cleansession = 1,
            .reliable = 1,
            .will = null,
            .username = zusername.ptr,
            .password = zpassword.ptr,
            .connectTimeout = 30,
            .retryInterval = 0,
            .ssl = null,
            .serverURIcount = 0,
            .serverURIs = null,
            .MQTTVersion = 0,
            .returned = .{
                .serverURI = null,
                .MQTTVersion = 0,
                .sessionPresent = 0,
            },
            .binarypwd = .{
                .len = 0,
                .data = null,
            },
            .maxInflightMessages = -1,
            .cleanstart = 0, // only available on V5 +
            .httpHeaders = null,
        };

        if (username.len == 0) {
            conn_options.username = null;
            conn_options.password = null;
        }

        var self_ptr = try allocator.create(Self);
        // init members
        self_ptr.handle = handle;
        self_ptr.allocator = allocator;
        self_ptr.callBack = _defaultCallback;
        self_ptr.latestDeliveryToken = try allocator.create(cmqtt.MQTTClient_deliveryToken);
        self_ptr.connected = false;
        // remember the connect options
        self_ptr.connect_option = try allocator.create(cmqtt.MQTTClient_connectOptions);
        self_ptr.connect_option.* = conn_options;
        self_ptr.reconnect_registered_topics = mem.zeroes([10]?[]u8);
        self_ptr.reconnect_registered_topics_length = 0;

        const retCallBacks = cmqtt.MQTTClient_setCallbacks(handle, self_ptr, _connLost, _msgArrived, _delivered);
        if (retCallBacks != cmqtt.MQTTCLIENT_SUCCESS) {
            return mqttlibError.FailToRegister;
        }
        try self_ptr.reconnect(true);
        return self_ptr;
    }

    fn reconnect(self: *Self, first: bool) !void {
        if (self.*.connected) {
            // nothing to do
            return;
        }

        if (!first) {
            const result = cmqtt.MQTTClient_disconnect(self.handle, 100);
            if (result != 0) {
                _ = c.printf("disconnection failed MQTTClient_disconnect returned %d, continue\n", result);
            }
        }

        const r = cmqtt.MQTTClient_connect(self.handle, self.connect_option);
        _ = c.printf("connect to mqtt returned %d\n", r);
        if (r != 0) return error.MQTTConnectError;
        self.connected = true;

        if (self.reconnect_registered_topics_length > 0) {
            for (self.reconnect_registered_topics[0..self.reconnect_registered_topics_length]) |e| {
                if (e) |nonNullPtr| {
                    _ = c.printf("re-registering %s \n", nonNullPtr.ptr);
                    self._register(nonNullPtr) catch {
                        _ = c.printf("cannot reregister \n");
                    };
                }
            }
        }
    }

    // publish a message with default QOS 0
    pub fn publish(self: *Self, topic: [*c]const u8, msg: []const u8) !void {
        return publishWithQos(self, topic, msg, 0);
    }

    pub fn publishWithQos(self: *Self, topic: [*c]const u8, msg: []const u8, qos: u8) !void {
        self._publishWithQos(topic, msg, qos) catch |e| {
            _ = c.printf("fail to publish, try to reconnect \n");
            log.warn("error : {}", .{e});
            self.connected = false;
            self.reconnect(false) catch |reconnecterr| {
                _ = c.printf("failed to reconnect, will retry later \n");
                log.warn("error: {}", .{reconnecterr});
            };
        };
    }

    // internal method, to permit to retry connect
    fn _publishWithQos(self: *Self, topic: [*c]const u8, msg: []const u8, qos: u8) !void {
        const messageLength: c_int = @intCast(msg.len);

        if (msg.len == 0) {
            return;
        }
        // beacause c declared the message as mutable (not const),
        // convert it to const type
        const constMessageContent: [*]u8 = @as([*]u8, @ptrFromInt(@intFromPtr(msg.ptr)));

        const HEADER_MESSAGE = [_]u8{ 'M', 'Q', 'T', 'M' };

        var mqttmessage = cmqtt.MQTTClient_message{
            .struct_id = HEADER_MESSAGE,
            .struct_version = 0, // no message properties
            .payloadlen = messageLength,
            .payload = constMessageContent,
            .qos = qos,
            .retained = 0,
            .dup = 0,
            .msgid = 0,
            // below, these are MQTTV5 specific properties
            .properties = cmqtt.MQTTProperties{
                .count = 0,
                .max_count = 0,
                .length = 0,
                .array = null,
            },
        };

        const token = try self.allocator.create(cmqtt.MQTTClient_deliveryToken);
        defer self.allocator.destroy(token);

        const resultPublish = cmqtt.MQTTClient_publishMessage(self.handle, topic, &mqttmessage, token);
        if (resultPublish != 0) {
            std.log.warn("publish mqtt message returned {}\n", .{resultPublish});
            return error.MQTTPublishError;
        }

        // wait for sent

        if (qos > 0) {
            const waitResult = cmqtt.MQTTClient_waitForCompletion(self.handle, token.*, @intCast(2000));
            if (waitResult != 0) return error.MQTTWaitTokenError;
            while (self.latestDeliveryToken.* != token.*) {
                // CPU breath, and yield
                _ = c.usleep(1);
            }
        }
    }

    pub fn register(self: *Self, topic: []const u8) !void {
        // remember the topic, to be able to re register at connection lost
        //
        if (self.*.reconnect_registered_topics_length >= self.reconnect_registered_topics.len) {
            // not enought room remember registered topics
            return error.TooMuchRegisteredTopics;
        }

        const ptr = try self.allocator.alloc(u8, topic.len + 1);
        @memcpy(ptr[0..topic.len], topic);
        ptr[topic.len] = '\x00';
        self.reconnect_registered_topics[self.*.reconnect_registered_topics_length] = ptr;
        self.reconnect_registered_topics_length = self.*.reconnect_registered_topics_length + 1;
        try self._register(ptr);
    }

    fn _register(self: *Self, topic: []const u8) !void {
        _ = c.printf("register to %s \n", topic.ptr);
        const r = cmqtt.MQTTClient_subscribe(self.*.handle, topic.ptr, 0);
        if (r != 0) return error.MQTTRegistrationError;
    }
};

test "testconnect mqtt home" {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const serverAddress: []const u8 = "tcp://192.168.4.16:1883";
    const clientid: []const u8 = "clientid";
    const userName: []const u8 = "sys";
    const password: []const u8 = "pwd";

    // var handle: cmqtt.MQTTClient = null;

    var cnx = try MqttCnx.init(allocator, serverAddress, clientid, userName, password);

    const myStaticMessage: []const u8 = "Hello static message";

    _ = try cnx.register("home/#");

    _ = c.sleep(10);

    var i: u32 = 0;
    while (i < 10000) : (i += 1) {
        try cnx.publish("myothertopic", myStaticMessage);
    }

    while (i < 10000) : (i += 1) {
        try cnx.publishWithQos("myothertopic", myStaticMessage, 1);
    }
    _ = c.printf("ended");
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const serverAddress: []const u8 = "tcp://192.168.4.16:1883";
    const clientid: []const u8 = "clientid";
    const userName: []const u8 = "sys";
    const password: []const u8 = "pwd";

    var cnx = try MqttCnx.init(allocator, serverAddress, clientid, userName, password);
    _ = try cnx.register("home/#");
    _ = c.sleep(20);
    _ = c.printf("ended");

    return;
}
