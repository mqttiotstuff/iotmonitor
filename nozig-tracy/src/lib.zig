
// This library mock the tracy calls

const std = @import("std");

pub const Ctx = struct {

    pub fn end(self: Ctx) void {
        // no op
        _ = self; 
    }
};


pub inline fn trace(comptime src: std.builtin.SourceLocation) Ctx {
    _ = src;
    return Ctx{
    };
}
