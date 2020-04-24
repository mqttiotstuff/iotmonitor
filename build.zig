const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const Builder = std.build.Builder;
const ArrayList = std.ArrayList;
const builtin = @import("builtin");
const Target = std.Target;

pub fn build(b: *Builder) void {
    const exe = b.addExecutable("iotmonitor", "iotmonitor.zig");
    exe.setBuildMode(builtin.Mode.Debug);
    // exe.setBuildMode(builtin.Mode.ReleaseFast);

    exe.addPackagePath("toml", "zig-toml/src/toml.zig");

    exe.setOutputDir("bin");
    // exe.setTarget(.{ .cpu = builtin.Arch.arm });

    // stripping symbols reduce the size of the exe
    // exe.strip = true;

    exe.linkLibC();

    exe.addLibPath("paho.mqtt.c/build/output");
    exe.addLibPath("paho.mqtt.c/src");
    // exe.linkSystemLibrary("paho-mqtt3c");
    exe.addObjectFile("paho.mqtt.c/src/libpaho-mqtt3c.a");

    // these libs are needed by leveldb backend
    exe.linkSystemLibrary("leveldb");
    // exe.addObjectFile("leveldb/libleveldb.a");
    // exe.linkSystemLibrary("c++");
    //exe.linkSystemLibrary("c++abi");

    // exe.setBuildMode(b.standardReleaseOptions());

    b.default_step.dependOn(&exe.step);
}
