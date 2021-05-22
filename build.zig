const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    // For library
    // const lib = b.addSharedLibrary("dross-zig", "src/dross_zig.zig", .unversioned);
    // lib.setBuildMode(mode);
    // lib.addIncludeDir("libs/glfw/include");
    // lib.addLibPath("libs/glfw/x64");
    // b.installBinFile("libs/glfw/x64/glfw3.dll", "glfw3.dll");

    // lib.addIncludeDir("libs/glad");
    // lib.addCSourceFile("libs/glad/src/glad.c", &[_][]const u8{"--std=c99"});

    // lib.addIncludeDir("libs/stb_image");
    // lib.addCSourceFile("libs/stb_image/stb_image_impl.c", &[_][]const u8{"--std=c17"});

    // lib.linkSystemLibrary("glfw3");
    // lib.linkSystemLibrary("opengl32");

    // lib.addPackage(.{
    //     .name = "zalgebra",
    //     .path = "libs/zalgebra/src/main.zig",
    // });

    // lib.linkLibC();
    // lib.install();

    // For executable
    const exe = b.addExecutable("dross-zig", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    // GLFW
    exe.addIncludeDir("libs/glfw/include");
    exe.addLibPath("libs/glfw/x64");
    exe.linkSystemLibrary("glfw3");
    b.installBinFile("libs/glfw/x64/glfw3.dll", "glfw3.dll");

    // GLAD
    exe.addIncludeDir("libs/glad");
    exe.addCSourceFile("libs/glad/src/glad.c", &[_][]const u8{"--std=c99"});

    // STB_IMAGE
    exe.addIncludeDir("libs/stb_image");
    exe.addCSourceFile("libs/stb_image/stb_image_impl.c", &[_][]const u8{"--std=c17"});

    // ZALGEBRA
    exe.addPackage(.{
        .name = "zalgebra",
        .path = "libs/zalgebra/src/main.zig",
    });

    exe.linkSystemLibrary("opengl32");

    // Copy over the resource code
    b.installBinFile("src/renderer/shaders/default_shader.vs", "assets/shaders/default_shader.vs");
    b.installBinFile("src/renderer/shaders/default_shader.fs", "assets/shaders/default_shader.fs");
    b.installBinFile("src/renderer/shaders/screenbuffer_shader.vs", "assets/shaders/screenbuffer_shader.vs");
    b.installBinFile("src/renderer/shaders/screenbuffer_shader.fs", "assets/shaders/screenbuffer_shader.fs");
    b.installBinFile("assets/sprites/s_guy_idle.png", "assets/sprites/s_guy_idle.png");
    b.installBinFile("assets/sprites/s_player.png", "assets/sprites/s_player.png");
    b.installBinFile("assets/sprites/s_enemy_01_idle.png", "assets/sprites/s_enemy_01_idle.png");
    b.installBinFile("assets/textures/t_default.png", "assets/textures/t_default.png");

    exe.linkLibC();

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
