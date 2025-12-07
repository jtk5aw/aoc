const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create executables for all 30 days
    const days = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 };

    for (days) |day| {
        const day_str = b.fmt("day-{d}", .{day});
        const src_path = b.fmt("src/day-{d}.zig", .{day});

        // Create executable for this day
        const exe = b.addExecutable(.{
            .name = day_str,
            .root_module = b.createModule(.{
                .root_source_file = b.path(src_path),
                .target = target,
                .optimize = optimize,
            }),
        });

        // Install the executable
        const install_exe = b.addInstallArtifact(exe, .{});

        // Create a build step for this day
        const build_step = b.step(day_str, b.fmt("Build day {d}", .{day}));
        build_step.dependOn(&install_exe.step);

        // Create a run step for this day
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(&install_exe.step);

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(b.fmt("run-{s}", .{day_str}), b.fmt("Run day {d}", .{day}));
        run_step.dependOn(&run_cmd.step);
    }
}
