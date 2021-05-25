// Third Parties
const c = @import("../c_global.zig").c_imp;
const std = @import("std");
const za = @import("zalgebra");

// dross-zig
const gl = @import("backend/backend_opengl.zig");
const Application = @import("../core/application.zig").Application;
const TextureId = @import("texture.zig").TextureId;
const Sprite = @import("sprite.zig").Sprite;
const Color = @import("../core/core.zig").Color;
const Camera = @import("../renderer/cameras/camera_2d.zig");
const Matrix4 = @import("../core/matrix4.zig").Matrix4;
const Vector3 = @import("../core/vector3.zig").Vector3;
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - BackendApi -
// -----------------------------------------
/// An enum to keep track of which graphics api is
/// being used, so the renderer can be api agnostic.
pub const BackendApi = enum(u8) {
    OpenGl,
    Vulkan,
    Dx12,
    //Metal, // Will probably never happen as it is such a smaller portion
};

pub const api: BackendApi = BackendApi.OpenGl;

// -----------------------------------------
//      - RendererErrors -
// -----------------------------------------
pub const RendererErrors = error{
    DuplicateRenderer,
};

// -----------------------------------------
//      - PackingMode -
// -----------------------------------------
pub const PackingMode = enum {
    /// Affects the packing of pixel data 
    Pack,
    /// Affects the unpacking of pixel data
    Unpack,
};

// -----------------------------------------
//      - ByteAlignment -
// -----------------------------------------
pub const ByteAlignment = enum {
    /// Byte-aligned
    One,
    /// Rows aligned to even-numbered bytes
    Two,
    /// Word-aligned
    Four,
    /// Rows start on double-word boundaries
    Eight,
};

// -----------------------------------------
//      - Renderer -
// -----------------------------------------
var renderer: *Renderer = undefined;

/// The main renderer for the application.
/// Meant to be MOSTLY backend agnostic.
pub const Renderer = struct {
    gl_backend: ?*gl.OpenGlBackend = undefined,

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

    /// Handles the rendering process
    /// Comments: INTERNAL use only.
    pub fn render(render_loop: fn () anyerror!void) void {
        var camera = Camera.getCurrentCamera();
        // Prepare for the user defined render
        Renderer.beginRender(camera.?);
        // Call user-defined render
        _ = render_loop() catch |err| {
            std.debug.print("[Renderer]: Render event encountered an error! {s}\n", .{err});
            @panic("[Renderer]: Error occurred during the user-defined render event!\n");
        };
        // Clean up
        Renderer.endRender();
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
    pub fn endRender() void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.endRender();
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Change the color the windows clears to.
    pub fn changeClearColor(color: Color) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.changeClearColor(color);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Sets up renderer to be able to draw a untextured quad.
    pub fn drawQuad(position: Vector3) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.drawQuad(position);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Sets up renderer to be able to draw a untextured quad.
    pub fn drawColoredQuad(position: Vector3, size: Vector3, color: Color) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.drawColoredQuad(position, size, color);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }
    /// Sets up renderer to be able to draw a textured quad.
    pub fn drawTexturedQuad(id: TextureId, position: Vector3) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.drawTexturedQuad(id, position);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Sets up renderer to be able to draw a Sprite.
    pub fn drawSprite(sprite: *Sprite, position: Vector3) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.drawSprite(sprite, position);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Request to disable byte_alignment restriction
    pub fn setByteAlignment(packing_mode: PackingMode, alignment: ByteAlignment) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.setByteAlignment(packing_mode, alignment);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Clears out the currently bound texture
    pub fn clearBoundTexture() void {
        switch (api) {
            BackendApi.OpenGl => {
                gl.OpenGlBackend.clearBoundTexture();
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

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

    /// Window resize callback for GLFW
    /// Comments: INTERNAL use only.
    pub fn resizeInternal(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
        var x_pos: c_int = 0;
        var y_pos: c_int = 0;

        c.glfwGetWindowPos(window, &x_pos, &y_pos);

        switch (api) {
            BackendApi.OpenGl => {
                c.glViewport(x_pos, y_pos, width, height);
                Application.setWindowSize(@intToFloat(f32, width), @intToFloat(f32, height));
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
