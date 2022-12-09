const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const Builder = std.build.Builder;
const ArrayList = std.ArrayList;
const builtin = @import("builtin");
const Target = std.Target;
const FileSource = std.build.FileSource;

pub fn build(b: *Builder) void {
    const exe = b.addExecutable("iotmonitor", "iotmonitor.zig");

    const target = b.standardTargetOptions(.{});
    exe.setTarget(target);
    exe.setBuildMode(b.standardReleaseOptions());

    exe.addPackagePath("toml", "zig-toml/src/toml.zig");
    exe.addPackagePath("clap", "zig-clap/clap.zig");
    exe.addPackage(.{
        .name = "routez",
        .source = FileSource.relative("routez/src/routez.zig"),
        .dependencies = &[_]std.build.Pkg{.{
            .name = "zuri",
            .source = FileSource.relative("routez/zuri/src/zuri.zig"),
        }},
    });

    const Activate_Tracy = false;

    if (Activate_Tracy) {
        exe.addPackage(.{ .name = "tracy", .source = FileSource.relative("zig-tracy/src/lib.zig") });
        exe.addIncludePath("tracy/");
        exe.addLibraryPath("tracy/library/unix");
        exe.linkSystemLibrary("tracy-debug");
    } else {
        exe.addPackage(.{ .name = "tracy", .source = FileSource.relative("nozig-tracy/src/lib.zig") });
    }

    exe.setOutputDir("bin");
    // exe.setTarget(.{ .cpu = builtin.Arch.arm });

    // stripping symbols reduce the size of the exe
    // exe.strip = true;
    exe.linkLibC();

    // static add the paho mqtt library
    exe.addIncludePath("paho.mqtt.c/src");
    exe.addLibraryPath("paho.mqtt.c/build/output");
    exe.addLibraryPath("paho.mqtt.c/src");
    exe.addObjectFile("paho.mqtt.c/src/libpaho-mqtt3c.a");

    // these libs are needed by leveldb backend
    exe.linkSystemLibrary("leveldb");

    b.default_step.dependOn(&exe.step);
}
