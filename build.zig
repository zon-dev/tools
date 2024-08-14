const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tools = b.addModule("tools", .{
        .root_source_file = b.path("src/tools.zig"),
        .target = target,
        .optimize = optimize,
    });

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/tools_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.root_module.addImport("tools", tools);
    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
