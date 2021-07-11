const std = @import("std");

pub const Ctx = struct {

    pub fn end(self: Ctx) void {
        // no op
    }
};


pub fn trace(comptime src: std.builtin.SourceLocation) callconv(.Inline) Ctx {
    return Ctx{
    };
}
