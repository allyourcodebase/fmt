# fmt-zig

Using `build.zig` integration for the [{fmt}](https://github.com/fmtlib/fmt) library - a modern formatting library providing a fast and safe alternative to C stdio and C++ iostreams.

Key features of {fmt}:
- Fast and efficient formatting with type-safe format strings
- Implements C++20 std::format
- Supports user-defined types
- Extensive formatting options and positional arguments
- Modern clean API design
- Header-only and compiled versions available

## Requirements

- [zig](https://ziglang.org/download) v0.14.0 or master

## How to build

Make directory and init

```bash
$ zig init
## add in 'build.zig.zon' fmt-zig package
$ zig fetch --save=fmt git+https://github.com/allyourcodebase/fmt-zig
```
Add in **build.zig**
```zig
const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const fmt_dep = b.dependency("fmt", .{
        .target = target,
        .optimize = optimize,
    });
    const fmt_artifact = fmt_dep.artifact("fmt");

    for(fmt_artifact.root_module.include_dirs.items) |include_dir| {
        try exe.root_module.include_dirs.append(b.allocator, include_dir);
    }
    exe.linkLibrary(fmt_artifact);
}
```