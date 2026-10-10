//! Minimal HTTP/1.1 server for the iotmonitor status endpoint.
const std = @import("std");
const Io = std.Io;

pub const Handler = *const fn (allocator: std.mem.Allocator, path: []const u8) anyerror![]u8;

pub fn listenAndServe(
    io: Io,
    bind_address: []const u8,
    port: u16,
    allocator: std.mem.Allocator,
    handler: Handler,
) !void {
    const address = try Io.net.IpAddress.parseIp4(bind_address, port);
    var server = try address.listen(io, .{ .mode = .stream, .reuse_address = true });
    defer server.deinit(io);

    while (true) {
        const stream = server.accept(io) catch continue;
        handleConnection(io, stream, allocator, handler) catch {};
    }
}

fn handleConnection(io: Io, stream: Io.net.Stream, allocator: std.mem.Allocator, handler: Handler) !void {
    defer stream.close(io);

    var read_buf: [4096]u8 = undefined;
    var write_buf: [4096]u8 = undefined;
    var reader = stream.reader(io, &read_buf);
    var writer = stream.writer(io, &write_buf);

    const head = reader.interface.takeDelimiterInclusive('\n') catch return;
    const path = parseRequestPath(head) orelse return;

    // Drain remaining request headers (best-effort).
    while (true) {
        const line = reader.interface.takeDelimiterInclusive('\n') catch break;
        if (line.len <= 2) break; // empty line \r\n
    }

    const body = handler(allocator, path) catch {
        try writer.interface.writeAll("HTTP/1.1 500 Internal Server Error\r\nConnection: close\r\nContent-Length: 0\r\n\r\n");
        try writer.interface.flush();
        return;
    };
    defer allocator.free(body);

    try writer.interface.print(
        "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {d}\r\nConnection: close\r\n\r\n",
        .{body.len},
    );
    try writer.interface.writeAll(body);
    try writer.interface.flush();
}

fn parseRequestPath(request_line: []const u8) ?[]const u8 {
    // "GET /path HTTP/1.1\r\n"
    var it = std.mem.tokenizeAny(u8, request_line, " \r\n");
    _ = it.next() orelse return null; // method
    return it.next();
}
