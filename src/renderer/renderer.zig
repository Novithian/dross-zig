// Third Parties
const c = @import("../c_global.zig").c_imp;
const std = @import("std");
const za = @import("zalgebra");

// dross-zig
const gl = @import("backend/backend_opengl.zig");
const Color = @import("../core/core.zig").Color;
const Camera = @import("../renderer/cameras/camera_2d.zig");
const EventLoop = @import("../core/event_loop.zig");
const Matrix4 = @import("../core/matrix4.zig").Matrix4;
const Vector3 = @import("../core/vector3.zig").Vector3;
// -----------------------------------------------------------------------------

/// An enum to keep track of which graphics api is
/// being used, so the renderer can be api agnostic.
pub const BackendApi = enum(u8) {
    OpenGl,
    Vulkan,
    Dx12,
    //Metal, // Will probably never happen as it is such a smaller portion
};

pub const api: BackendApi = BackendApi.OpenGl;

pub const RendererErrors = error{
    DuplicateRenderer,
};

// -----------------------------------------
//      - Renderer -
// -----------------------------------------
var renderer: *Renderer = undefined;

/// The main renderer for the application.
/// Meant to be MOSTLY backend agnostic.
pub const Renderer = struct {
    gl_backend: ?*gl.OpenGlBackend = undefined,
    clear_color: Color,

    /// Resizes the viewport to the given size and position 
    /// Comments: INTERNAL use only.
    pub fn resizeViewport(x: c_int, y: c_int, width: c_int, height: c_int) void {
        switch (api) {
            BackendApi.OpenGl => {
                gl.resizeViewport(x, y, width, height);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Handles the rendering process
    /// Comments: INTERNAL use only.
    pub fn render() void {
        var camera = Camera.getCurrentCamera();
        // Prepare for the user defined render
        Renderer.beginRender(camera.?);
        // Call user-defined render
        EventLoop.renderInternal();
        // Clean up
        Renderer.endRender();
    }

    /// Builds the graphics API
    /// Comments: INTERNAL use only. The Renderer will be the owner of the allocated memory.
    pub fn build(self: *Renderer, allocator: *std.mem.Allocator) anyerror!void {
        switch (api) {
            BackendApi.OpenGl => {
                self.gl_backend = try gl.build(allocator);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Frees any allocated memory that the Renderer owns
    /// Comments: INTERNAL use only.
    pub fn free(self: *Renderer, allocator: *std.mem.Allocator) void {
        switch (api) {
            BackendApi.OpenGl => {
                self.gl_backend.?.free(allocator);
                allocator.destroy(self.gl_backend.?);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Flags and sets up for the start of the user-defined render event
    /// Comments: INTERNAL use only.
    pub fn beginRender(camera: *Camera.Camera2d) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.beginRender(camera);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Handles the clean up for the end of the user-defined render event
    /// Comments: INTERNAL use only.
    pub fn endRender() void {}

    pub fn drawQuad(position: Vector3) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.drawQuad(position);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Window resize callback for GLFW
    /// Comments: INTERNAL use only.
    pub fn resizeInternal(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
        var x_pos: c_int = 0;
        var y_pos: c_int = 0;

        c.glfwGetWindowPos(window, &x_pos, &y_pos);

        switch (api) {
            BackendApi.OpenGl => {
                c.glViewport(x_pos, y_pos, width, height);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }
};

/// Allocates and builds the renderer
/// Comments: INTERNAL use only. The Application will own and
/// control the lifetime of the Renderer.
pub fn buildRenderer(allocator: *std.mem.Allocator) anyerror!void {
    //if (renderer != undefined) return;
    renderer = try allocator.create(Renderer);

    try renderer.build(allocator);
}

/// Ensures the Renderer cleans up and frees any allocated memory
pub fn freeRenderer(allocator: *std.mem.Allocator) !void {
    if (renderer == undefined) return;

    renderer.free(allocator);
    allocator.destroy(renderer);
}
