const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const clap_dep = b.dependency("clap", .{});
    const clap_mod = clap_dep.module("clap");

    const toml_mod = b.createModule(.{
        .root_source_file = b.path("zig-toml/src/toml.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tracy_mod = b.createModule(.{
        .root_source_file = b.path("nozig-tracy/src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const root_mod = b.createModule(.{
        .root_source_file = b.path("iotmonitor.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{
            .{ .name = "clap", .module = clap_mod },
            .{ .name = "toml", .module = toml_mod },
            .{ .name = "tracy", .module = tracy_mod },
        },
    });

    root_mod.addIncludePath(b.path("paho.mqtt.c/src"));
    root_mod.addObjectFile(b.path("paho.mqtt.c/src/libpaho-mqtt3c.a"));
    root_mod.linkSystemLibrary("leveldb", .{});

    const exe = b.addExecutable(.{
        .name = "iotmonitor",
        .root_module = root_mod,
    });

    b.installArtifact(exe);

    const install_bin = b.addInstallFile(
        exe.getEmittedBin(),
        "../bin/iotmonitor",
    );
    install_bin.step.dependOn(&exe.step);
    b.getInstallStep().dependOn(&install_bin.step);
}
