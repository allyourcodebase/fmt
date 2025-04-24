const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Options
    const shared = b.option(bool, "shared", "Build the Shared Library [default: false]") orelse false;
    const tests = b.option(bool, "tests", "Build tests [default: false]") orelse false;

    const fmt_dep = b.dependency("fmt", .{
        .target = target,
        .optimize = optimize,
    });

    const lib = if (shared) b.addSharedLibrary(.{
        .name = "fmt",
        .target = target,
        .optimize = optimize,
        .version = .{
            .major = 11,
            .minor = 1,
            .patch = 4,
        },
    }) else b.addStaticLibrary(.{
        .name = "fmt",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(fmt_dep.path("include"));
    lib.addCSourceFiles(.{
        .root = fmt_dep.path("src"),
        .files = src,
    });
    if (optimize == .Debug or optimize == .ReleaseSafe)
        lib.bundle_compiler_rt = true
    else
        lib.root_module.strip = true;
    if (lib.linkage == .static)
        lib.pie = true;
    if (lib.rootModuleTarget().abi != .msvc)
        lib.linkLibCpp()
    else
        lib.linkLibC();
    lib.installHeadersDirectory(fmt_dep.path("include"), "", .{});
    b.installArtifact(lib);

    if (tests) {
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "args-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "base-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "unicode-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "assert-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "std-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "xchar-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "ostream-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "printf-test.cc",
        });
        // FIXME: duplicate symbols error
        // buildTest(b, .{
        //     .optimize = optimize,
        //     .target = target,
        //     .lib = lib,
        //     .dep = fmt_dep,
        //     .path = "scan-test.cc",
        // });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "ranges-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "color-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "chrono-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "compile-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "compile-fp-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "format-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "os-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "noexception-test.cc",
        });
        buildTest(b, .{
            .optimize = optimize,
            .target = target,
            .lib = lib,
            .dep = fmt_dep,
            .path = "posix-mock-test.cc",
        });
        // FIXME: https://github.com/ziglang/zig/issues/15496
        // buildTest(b, .{
        //     .optimize = optimize,
        //     .target = target,
        //     .lib = lib,
        //     .dep = fmt_dep,
        //     .path = "module-test.cc",
        // });
    }
}

fn buildTest(b: *std.Build, info: BuildInfo) void {
    const test_exe = b.addExecutable(.{
        .name = info.filename(),
        .optimize = info.optimize,
        .target = info.target,
    });
    for (info.lib.root_module.include_dirs.items) |include_dir| {
        test_exe.root_module.include_dirs.append(b.allocator, include_dir) catch unreachable;
    }
    if (info.dep) |dep_test| {
        test_exe.addIncludePath(dep_test.path("test"));
        test_exe.addIncludePath(dep_test.path("test/gtest"));
        test_exe.addIncludePath(dep_test.path("test/gmock"));

        test_exe.addCSourceFiles(.{
            .root = dep_test.path("test"),
            .files = &.{info.path},
        });
        test_exe.addCSourceFiles(.{
            .root = dep_test.path("test/gtest"),
            .files = &.{"gmock-gtest-all.cc"},
        });
        test_exe.addCSourceFiles(.{
            .root = dep_test.path("test"),
            .files = test_src,
            .flags = &.{
                "-Wall",
                "-Wextra",
                "-Wno-deprecated-declarations",
            },
        });
    }
    test_exe.root_module.addCMacro("_SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING", "1");
    test_exe.root_module.addCMacro("GTEST_HAS_PTHREAD", "0");
    test_exe.linkLibrary(info.lib);
    if (test_exe.rootModuleTarget().abi != .msvc)
        test_exe.linkLibCpp()
    else
        test_exe.linkLibC();
    b.installArtifact(test_exe);

    const run_cmd = b.addRunArtifact(test_exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(
        b.fmt("{s}", .{info.filename()}),
        b.fmt("Run the {s} test", .{info.filename()}),
    );
    run_step.dependOn(&run_cmd.step);
}

const src: []const []const u8 = &.{
    "format.cc",
    "os.cc",
};
const test_src: []const []const u8 = &.{
    "gtest-extra.cc",
    "enforce-checks-test.cc",
    "util.cc",
};

const BuildInfo = struct {
    lib: *std.Build.Step.Compile,
    optimize: std.builtin.OptimizeMode,
    target: std.Build.ResolvedTarget,
    path: []const u8,
    dep: ?*std.Build.Dependency = null,

    fn filename(self: BuildInfo) []const u8 {
        var split = std.mem.splitSequence(u8, std.fs.path.basename(self.path), ".");
        return split.first();
    }
};
