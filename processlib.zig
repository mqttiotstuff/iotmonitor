// process lib, permit to launch loosely coupled processes

const std = @import("std");
const debug = std.debug;
const os = std.os;
const mem = std.mem;
const fs = std.fs;
const File = fs.File;
const Dir = fs.Dir;
const fmt = std.fmt;

pub const ProcessInformation = struct {
    pid: u64 = 0,
    // 8k for buffer ? is it enought ?
    commandlinebuffer: [8192]u8 = [_]u8{'\x00'} ** 8192,
    commandlinebuffer_size: u16 = 0,
    const Self = @This();

    // iterator on the command line arguments
    const Iterator = struct {
        inner: *const Self,
        currentIndex: u16 = 0,

        const SelfIterator = @This();
        pub fn next(self: *SelfIterator) ?[]const u8 {
            if (self.currentIndex >= self.inner.commandlinebuffer_size) {
                return null;
            }
            const start = self.currentIndex;
            while (self.currentIndex < self.inner.commandlinebuffer_size and self.inner.commandlinebuffer[self.currentIndex] != '\x00') {
                self.currentIndex = self.currentIndex + 1;
            }
            self.currentIndex = self.currentIndex + 1;
            return self.inner.commandlinebuffer[start..self.currentIndex];
        }
    };
    pub fn iterator(processInfo: *Self) Iterator {
        return Iterator{ .inner = processInfo };
    }
};

// get process information, for a specific PID
// return false if the process does not exists,
// return true and the processInfo is populated with the command line options
pub fn getProcessInformations(pid: i32, processInfo: *ProcessInformation) !bool {
    var buffer = [_]u8{'\x00'} ** 8192;

    const options = Dir.OpenDirOptions{
        .access_sub_paths = true,
        .iterate = true,
    };
    var procDir = try fs.cwd().openDir("/proc", options);
    defer procDir.close();

    const r = try fmt.bufPrint(&buffer, "{}", .{pid});
    var subprocDir: Dir = procDir.openDir(r, options) catch |e| {
        return false;
    };
    defer subprocDir.close();

    const flags = File.OpenFlags{ .read = false };
    var commandLineFile: File = try subprocDir.openFile("cmdline", File.OpenFlags{});
    defer commandLineFile.close();

    const readSize = try commandLineFile.pread(processInfo.commandlinebuffer[0..], 0);
    processInfo.commandlinebuffer_size = @intCast(u16, readSize);

    return true;
}

// test if buffer contains only digits
fn isAllNumeric(buffer: []const u8) bool {
    var isNumeric = true;
    for (buffer) |c| {
        if (c > '9' or c < '0') {
            return false;
        }
    }
    return true;
}
// Process browsing
//
const ProcessInformationCallback = fn (processInformation: *ProcessInformation) void;

// function that list processes and grab command line arguments
// a call back is taken from
pub fn listProcesses(callback: ProcessInformationCallback) !void {
    const options = Dir.OpenDirOptions{
        .access_sub_paths = true,
        .iterate = true,
    };
    var procDir = try fs.cwd().openDir("/proc", options);
    defer procDir.close();

    var dirIterator = procDir.iterate();
    while (try dirIterator.next()) |f| {
        if (f.kind == File.Kind.File) {
            continue;
        }

        if (!isAllNumeric(f.name)) {
            continue;
        }

        const pid = try fmt.parseInt(u64, f.name, 10);
        var pi = ProcessInformation{};
        const successGetInformations = try getProcessInformations(pid, &pi);
        if (successGetInformations and pi.commandlinebuffer_size > 0) {
            callback(&pi);
            debug.warn(" {}: {} \n", .{ pid, pi.commandlinebuffer[0..pi.commandlinebuffer_size] });
        }
        // try opening the commandline file
    }
}

fn testCallback(processInformation: *ProcessInformation) void {
    debug.warn("processinformation : {}", .{processInformation});
    // dump the commnand line buffer
    var it = processInformation.iterator();
    while (it.next()) |i| {
        debug.warn("     {}\n", .{i});
    }
}

test "check existing process" {
    try listProcesses(testCallback);
}
