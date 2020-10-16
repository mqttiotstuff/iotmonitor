const std = @import("std");
const mem = std.mem;

const cmqtt = @import("mqtt_paho.zig");
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("unistd.h");
    @cInclude("string.h");
    @cInclude("time.h");
});

const CallBack = fn (topic: []u8, message: []u8) void;

const MAX_REGISTERED_TOPICS = 10;

// Connexion to mqtt
//
pub const MqttCnx = struct {
    const Self = @This();

    allocator: *mem.Allocator,
    handle: cmqtt.MQTTClient = undefined,
    callBack: CallBack = undefined,
    latestDeliveryToken: *cmqtt.MQTTClient_deliveryToken = undefined,
    connected: bool = undefined,
    connect_option: *cmqtt.MQTTClient_connectOptions = undefined,

    reconnect_registered_topics_length: u16 = 0,
    reconnect_registered_topics: [10]?[]u8,

    // this message is received in an other thread
    fn _defaultCallback(topic: []u8, message: []u8) void {
        _ = c.printf("%s", &message[0]);
    }

    fn _connLost(ctx: ?*c_void, m: [*c]u8) callconv(.C) void {
        const self_ctx = @intToPtr(*Self, @ptrToInt(ctx));
        _ = c.printf("connection lost");
    }

    fn _msgArrived(ctx: ?*c_void, topic: [*c]u8, topic_length: c_int, message: [*c]cmqtt.MQTTClient_message) callconv(.C) c_int {
        const messagePtrAddress = @ptrToInt(&message);
        var cmsg = @intToPtr([*c][*c]cmqtt.MQTTClient_message, messagePtrAddress);
        defer cmqtt.MQTTClient_freeMessage(cmsg);
        defer cmqtt.MQTTClient_free(topic);

        // unsafe conversion
        const self_ctx = @intToPtr(*Self, @ptrToInt(ctx));

        // paho always return a 0 in topic_length, we must then compute it
        // _ = c.printf("topic length is %d \n", topic_length);

        const tlength: usize = c.strlen(topic);
        const mlength = @intCast(u32, message.*.payloadlen);

        const am = @ptrToInt(message.*.payload);
        const mptr = @intToPtr([*]u8, am);
        // pass to zig in proper way with slices
        self_ctx.callBack(topic[0..tlength], mptr[0..mlength]);
        return 1; // properly handled
    }

    fn _delivered(ctx: ?*c_void, token: cmqtt.MQTTClient_deliveryToken) callconv(.C) void {
        // _ = c.printf("%s", "received token");
        // unsafe conversion
        const self_ctx = @intToPtr(*Self, @ptrToInt(ctx));

        self_ctx.*.latestDeliveryToken.* = token;
    }

    pub fn deinit(self: *Self) !void {}

    pub fn init(allocator: *mem.Allocator, serverAddress: []const u8, clientid: []const u8, username: []const u8, password: []const u8) !*Self {
        var handle: cmqtt.MQTTClient = undefined;

        // we need to make a safe string with zero ending
        const zServerAddress = try allocator.alloc(u8, serverAddress.len + 1);
        // defer allocator.free(zServerAddress);
        mem.copy(u8, zServerAddress, serverAddress[0..]);
        zServerAddress[serverAddress.len] = '\x00';

        const zusername = try allocator.alloc(u8, username.len + 1);
        // defer allocator.free(zusername);
        mem.copy(u8, zusername, username[0..]);
        zusername[username.len] = '\x00';

        const zpassword = try allocator.alloc(u8, password.len + 1);
        // defer allocator.free(zpassword);
        mem.copy(u8, zpassword, password[0..]);
        zpassword[password.len] = '\x00';

        const zclientid = try allocator.alloc(u8, clientid.len + 1);
        // defer allocator.free(zclientid);
        mem.copy(u8, zclientid, clientid[0..]);
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
        _ = c.printf("connect to mqtt returned %d\n\x00", r);
        if (r != 0) return error.MQTTConnectError;
        self.connected = true;

        if (self.reconnect_registered_topics_length > 0) {
            for (self.reconnect_registered_topics[0..self.reconnect_registered_topics_length]) |e| {
                if (e) |nonNullPtr| {
                    _ = c.printf("re-registering %s \n", nonNullPtr.ptr);
                    self._register(nonNullPtr) catch |errregister| {
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
            self.connected = false;
            self.reconnect(false) catch {
                _ = c.printf("failed to reconnect, will retry later \n");
            };
        };
    }

    // internal method, to permit to retry connect
    fn _publishWithQos(self: *Self, topic: [*c]const u8, msg: []const u8, qos: u8) !void {
        const messageLength: c_int = @intCast(c_int, msg.len);

        if (msg.len == 0) {
            return;
        }
        // beacause c declared the message as mutable (not const),
        // convert it to const type
        const constMessageContent: [*]u8 = @intToPtr([*]u8, @ptrToInt(msg.ptr));

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

        var token = try self.allocator.create(cmqtt.MQTTClient_deliveryToken);
        defer self.allocator.destroy(token);

        const resultPublish = cmqtt.MQTTClient_publishMessage(self.handle, topic, &mqttmessage, token);
        if (resultPublish != 0) {
            std.debug.warn("publish mqtt message returned {}\n", .{resultPublish});
            return error.MQTTPublishError;
        }

        // wait for sent

        if (qos > 0) {
            const waitResult = cmqtt.MQTTClient_waitForCompletion(self.handle, token.*, @intCast(c_ulong, 2000));
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
        mem.copy(u8, ptr, topic[0..]);
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
    const allocator = &arena.allocator;

    var serverAddress: []const u8 = "tcp://192.168.4.16:1883";
    var clientid: []const u8 = "clientid";
    var userName: []const u8 = "sys";
    var password: []const u8 = "pwd";

    var handle: cmqtt.MQTTClient = null;

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
    const allocator = &arena.allocator;

    var serverAddress: []const u8 = "tcp://192.168.4.16:1883";
    var clientid: []const u8 = "clientid";
    var userName: []const u8 = "sys";
    var password: []const u8 = "pwd";

    var handle: cmqtt.MQTTClient = null;

    var cnx = try MqttCnx.init(allocator, serverAddress, clientid, userName, password);

    const myStaticMessage: []const u8 = "Hello static message";

    _ = try cnx.register("home/#");

    _ = c.sleep(20);
    //var i : u32=0;
    //while (i < 10000): ( i+= 1) {
    //    try cnx.publish("myothertopic", myStaticMessage);
    //}

    _ = c.printf("ended");

    return;
}
