
// This library mock the tracy calls

const std = @import("std");

pub const Ctx = struct {

    pub fn end(self: Ctx) void {
        // no op
        _ = self; 
    }
};


pub fn trace(comptime src: std.builtin.SourceLocation) callconv(.Inline) Ctx {
    _ = src;
    return Ctx{
    };
}
