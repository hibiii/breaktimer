const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const main_exe = b.addExecutable(.{
        .name = "bktimer",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_exe.linkLibC();
    main_exe.linkSystemLibrary("raylib");

    b.installArtifact(main_exe);

    const run_main = b.addRunArtifact(main_exe);

    run_main.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_main.addArgs(args);
    }

    const run_step = b.step("run-main", "Run brktimer");
    run_step.dependOn(&run_main.step);

    // const unit_tests = b.addTest(.{
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // const run_unit_tests = b.addRunArtifact(unit_tests);

    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_unit_tests.step);
}
