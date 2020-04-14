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
// Connexion to mqtt
//
pub const MqttCnx = struct {
    const Self = @This();

    allocator: *mem.Allocator,
    handle: cmqtt.MQTTClient = undefined,
    callBack: CallBack = undefined,
    latestDeliveryToken: *cmqtt.MQTTClient_deliveryToken = undefined,

    // this message is received in an other thread
    fn _defaultCallback(topic: []u8, message: []u8) void {
        _ = c.printf("%s", &message[0]);
    }

    fn _connLost(ctx: ?*c_void, m: [*c]u8) callconv(.C) void {
        //        const self : *MqttCnx = @ptrCast(*MqttCnx,ctx);
    }

    fn _msgArrived(ctx: ?*c_void, topic: [*c]u8, topic_length: c_int, message: [*c]cmqtt.MQTTClient_message) callconv(.C) c_int {
        const cpm = @ptrToInt(&message);
        var cmsg = @intToPtr([*c][*c]cmqtt.MQTTClient_message, cpm);
        defer cmqtt.MQTTClient_freeMessage(cmsg);
        defer cmqtt.MQTTClient_free(topic);

        // unsafe conversion
        const self_ctx = @intToPtr(*Self, @ptrToInt(ctx));

        // _ = c.printf("received %s \n", topic);

        // paho always return a 0 in topic_length, we must then compute it
        // _ = c.printf("topic length is %d \n", topic_length);

        const tlength: usize = c.strlen(topic);
        const mlength = @intCast(u32, message.*.payloadlen);

        const am = @ptrToInt(message.*.payload);
        const mptr = @intToPtr([*]u8, am);
        // pass to zig in proper way (slices)
        self_ctx.callBack(topic[0..tlength], mptr[0..mlength]);
        return 1; // properly handled
    }

    fn _delivered(ctx: ?*c_void, token: cmqtt.MQTTClient_deliveryToken) callconv(.C) void {
        // _ = c.printf("%s", "received token");
        // unsafe conversion
        const self_ctx = @intToPtr(*Self, @ptrToInt(ctx));

        self_ctx.*.latestDeliveryToken.* = token;
    }

    pub fn init(allocator: *mem.Allocator, serverAddress: []const u8, clientid: []const u8, username: []const u8, password: []const u8) !*Self {
        var handle: cmqtt.MQTTClient = undefined;

        // we need to make a safe string with zero ending
        const zServerAddress = try allocator.alloc(u8, serverAddress.len + 1);
        defer allocator.free(zServerAddress);
        mem.copy(u8, zServerAddress, serverAddress[0..]);
        zServerAddress[serverAddress.len] = '\x00';

        const zusername = try allocator.alloc(u8, username.len + 1);
        defer allocator.free(zusername);
        mem.copy(u8, zusername, username[0..]);
        zusername[username.len] = '\x00';

        const zpassword = try allocator.alloc(u8, password.len + 1);
        defer allocator.free(zpassword);
        mem.copy(u8, zpassword, password[0..]);
        zpassword[password.len] = '\x00';

        const zclientid = try allocator.alloc(u8, clientid.len + 1);
        defer allocator.free(zclientid);
        mem.copy(u8, zclientid, clientid[0..]);
        zclientid[clientid.len] = '\x00';

        // convert to C the input parameters (ensuring the sentinel)
        const result = cmqtt.MQTTClient_create(&handle, zServerAddress.ptr, zclientid.ptr, 0, null);

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

        if (username.len ==0) { conn_options.username = null; conn_options.password = null; }

        var self_ptr = try allocator.create(Self);
        self_ptr.handle = handle;
        self_ptr.allocator = allocator;
        self_ptr.callBack = _defaultCallback;
        self_ptr.latestDeliveryToken = try allocator.create(cmqtt.MQTTClient_deliveryToken);

        const retCallBacks = cmqtt.MQTTClient_setCallbacks(handle, self_ptr, _connLost, _msgArrived, _delivered);

        const r = cmqtt.MQTTClient_connect(handle, &conn_options);
        _ = c.printf("connect to mqtt returned %d\n\x00", r);
        if (r != 0) return error.MQTTConnectError;

        return self_ptr;
    }

    pub fn publish(self: *Self, topic: [*c]const u8, msg: []const u8) !void {
        return publishWithQos(self, topic, msg, 0);
    }

    pub fn publishWithQos(self: *Self, topic: [*c]const u8, msg: []const u8, qos: u8) !void {
        const messageLength: c_int = @intCast(c_int, msg.len);

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
        if (resultPublish != 0) return error.MQTTPublishError;

        // wait for sent

        if (qos > 0) {
            const waitResult = cmqtt.MQTTClient_waitForCompletion(self.handle, token.*, @intCast(c_ulong, 2000));
            if (waitResult != 0) return error.MQTTWaitTokenError;
            while (self.latestDeliveryToken.* != token.*) {
                // CPU breath
                _ = c.usleep(1);
            }
        }
    }

    pub fn register(self: *Self, topic: []const u8) !void {
        const r = cmqtt.MQTTClient_subscribe(self.handle, topic.ptr, 0);
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
