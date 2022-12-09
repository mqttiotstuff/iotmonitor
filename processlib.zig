// process lib, permit to launch loosely coupled processes

const std = @import("std");
const debug = std.debug;
const log = std.log;
const os = std.os;
const mem = std.mem;
const fs = std.fs;
const File = fs.File;
const Dir = fs.Dir;
const fmt = std.fmt;

pub const ProcessInformation = struct {
    pid: i32 = 0,
    // 8k for buffer ? is it enought ?
    commandlinebuffer: [BUFFERSIZE]u8 = [_]u8{'\x00'} ** BUFFERSIZE,
    commandlinebuffer_size: u16 = 0,
    const Self = @This();

    const BUFFERSIZE = 8292 * 2;

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
            // seek for next 0 ending or end of commandline buffer_size
            while (self.currentIndex < self.inner.commandlinebuffer_size and self.inner.commandlinebuffer[self.currentIndex] != '\x00') {
                self.currentIndex = self.currentIndex + 1;
            }
            // move to next after returning the element slice
            defer self.currentIndex = self.currentIndex + 1;
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
    };
    var procDir = try fs.cwd().openDir("/proc", options);
    defer procDir.close();

    const r = try fmt.bufPrint(&buffer, "{}", .{pid});
    var subprocDir: Dir = procDir.openDir(r, options) catch {
        log.warn("no dir associated to proc {}", .{pid});
        return false;
    };
    defer subprocDir.close();

    var commandLineFile: File = try subprocDir.openFile("cmdline", File.OpenFlags{});
    defer commandLineFile.close();

    const readSize = try commandLineFile.pread(processInfo.commandlinebuffer[0..], 0);
    processInfo.commandlinebuffer_size = @intCast(u16, readSize);

    processInfo.*.pid = pid;

    return true;
}

// test if buffer contains only digits
fn isAllNumeric(buffer: []const u8) bool {
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
        // .iterate = true,
    };
    var procDir = try fs.cwd().openIterableDir("/proc", options);
    defer procDir.close();

    var dirIterator = procDir.iterate();
    while (try dirIterator.next()) |f| {
        if (f.kind == File.Kind.File) {
            continue;
        }

        if (!isAllNumeric(f.name)) {
            continue;
        }

        const pid = try fmt.parseInt(i32, f.name, 10);
        var pi = ProcessInformation{};
        const successGetInformations = getProcessInformations(pid, &pi) catch {
            // if file retrieve failed because of pid close, continue
            continue;
        };
        if (successGetInformations and pi.commandlinebuffer_size > 0) {
            callback(&pi);
            // log.warn(" {}: {} \n", .{ pid, pi.commandlinebuffer[0..pi.commandlinebuffer_size] });
        }
        // try opening the commandline file
    }
}

fn testCallback(processInformation: *ProcessInformation) void {
    log.warn("processinformation : {}", .{processInformation});
    // dump the commnand line buffer
    var it = processInformation.iterator();
    while (it.next()) |i| {
        log.warn("     {}\n", .{i});
    }
}

test "check existing process" {
    try listProcesses(testCallback);
}
