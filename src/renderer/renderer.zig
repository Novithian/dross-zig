// Third Parties
const c = @import("../c_global.zig").c_imp;
const std = @import("std");
const za = @import("zalgebra");

// dross-zig
const gl = @import("backend/renderer_opengl.zig");
const RendererGl = gl.RendererGl;
const app = @import("../core/application.zig");
const Application = app.Application;
const TextureId = @import("texture.zig").TextureId;
const Sprite = @import("sprite.zig").Sprite;
const Color = @import("../core/color.zig").Color;
const Camera = @import("../renderer/cameras/camera_2d.zig");
const Matrix4 = @import("../core/matrix4.zig").Matrix4;
const Vector3 = @import("../core/vector3.zig").Vector3;
const Vector2 = @import("../core/vector2.zig").Vector2;
const FrameStatistics = @import("../utils/profiling/frame_statistics.zig").FrameStatistics;
const String = @import("../utils/strings.zig");
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
    gl_backend: ?*RendererGl = undefined,

    /// Allocates and builds a Renderer instance
    /// Comments: INTERNAL use only. The Renderer will be the owner of the allocated memory.
    pub fn new(allocator: *std.mem.Allocator) anyerror!void {
        renderer = try allocator.create(Renderer);

        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend = try RendererGl.new(allocator);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Frees any allocated memory that the Renderer owns
    /// Comments: INTERNAL use only.
    pub fn free(allocator: *std.mem.Allocator) void {
        if (renderer == undefined) return;

        switch (api) {
            BackendApi.OpenGl => {
                RendererGl.free(allocator, renderer.gl_backend.?);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }

        allocator.destroy(renderer);
    }

    /// Handles the rendering process
    /// Comments: INTERNAL use only.
    pub fn render(render_loop: fn () anyerror!void, gui_render_loop: fn () anyerror!void) void {
        var camera = Camera.currentCamera();
        // Prepare for the user defined render loop
        Renderer.beginRender(camera.?);

        // Call user-defined render
        _ = render_loop() catch |err| {
            std.debug.print("[Renderer]: Render event encountered an error! {s}\n", .{err});
            @panic("[Renderer]: Error occurred during the user-defined render event!\n");
        };

        // Submit the framebuffer to be renderered
        Renderer.endRender();

        // Prepare the user-defined gui render loop
        Renderer.beginGui();

        // Call user-defined gui render
        _ = gui_render_loop() catch |err| {
            std.debug.print("[Renderer]: Render event encountered an error! {s}\n", .{err});
            @panic("[Renderer]: Error occurred during the user-defined render event!\n");
        };

        // Profiling stats
        if (!app.debug_mode) {
            Renderer.endGui();
            return;
        }

        const window_size = Application.windowSize();
        const string_height = 30.0;
        const top_padding = 0.0;
        const left_padding = 20.0;
        const window_size_y = window_size.y();
        const background_size = Vector3.new(window_size.x() * 0.25, 100 + top_padding + (string_height * 5.0), 0.0);
        var background_color = Color.darkGray();
        const background_opacity = 0.5;
        background_color.a = background_opacity;

        // Draw background window
        //Renderer.drawColoredQuadGui(Vector3.new(0.0, window_size_y - background_size.y(), 0.0), background_size, background_color);

        // Populate Stats
        const frame_time: f64 = FrameStatistics.frameTime();
        const update_time: f64 = FrameStatistics.updateTime();
        const draw_time: f64 = FrameStatistics.drawTime();
        var draw_calls: i64 = FrameStatistics.drawCalls();
        var quad_count: i64 = FrameStatistics.quadCount();

        var frame_time_buffer: [128]u8 = undefined;
        var update_time_buffer: [128]u8 = undefined;
        var draw_time_buffer: [128]u8 = undefined;
        var draw_calls_buffer: [128]u8 = undefined;
        var quad_count_buffer: [128]u8 = undefined;

        var frame_time_string = String.format(&frame_time_buffer, "Frame (ms): {d:5}", .{frame_time});
        var update_time_string = String.format(&update_time_buffer, "User Update (ms): {d:5}", .{update_time});
        var draw_time_string = String.format(&draw_time_buffer, "Draw (ms): {d:6}", .{draw_time});

        draw_calls += 1;
        quad_count += @intCast(i64, frame_time_string.len);
        quad_count += @intCast(i64, update_time_string.len);
        quad_count += @intCast(i64, draw_time_string.len);

        var draw_calls_string = String.format(&draw_calls_buffer, "Draw Calls: {}", .{draw_calls});
        quad_count += @intCast(i64, draw_calls_string.len);
        var quad_count_string = String.format(&quad_count_buffer, "Quad Count: {}", .{quad_count});
        quad_count += @intCast(i64, draw_calls_string.len);

        // Draw Stats
        Renderer.drawText(frame_time_string, left_padding, window_size_y - top_padding - (string_height * 1.0), 1.0, Color.white());
        Renderer.drawText(update_time_string, left_padding, window_size_y - top_padding - (string_height * 2.0), 1.0, Color.white());
        Renderer.drawText(draw_time_string, left_padding, window_size_y - top_padding - (string_height * 3.0), 1.0, Color.white());
        Renderer.drawText(draw_calls_string, left_padding, window_size_y - top_padding - (string_height * 4.0), 1.0, Color.white());
        Renderer.drawText(quad_count_string, left_padding, window_size_y - top_padding - (string_height * 5.0), 1.0, Color.white());

        // Submit the gui to be renderered
        Renderer.endGui();
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

    /// Flags and sets up for the start of the user-defined gui event
    /// Comments: INTERNAL use only.
    pub fn beginGui() void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.beginGui();
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

    /// Handles the clean up for the end of the user-defined gui event
    /// Comments: INTERNAL use only.
    pub fn endGui() void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.endGui();
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

    pub fn drawColoredQuadGui(position: Vector3, size: Vector3, color: Color) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.drawColoredQuadGui(position, size, color);
            },
            BackendApi.Dx12 => {},
            BackendApi.Vulkan => {},
        }
    }

    /// Sets up renderer to be able to draw a textured quad.
    pub fn drawTexturedQuad(texture_id: TextureId, position: Vector3, scale: Vector2, color: Color) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.drawTexturedQuad(texture_id, position, scale, color);
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

    /// Sets up the renderer to be able to draw text
    pub fn drawText(text: []const u8, x: f32, y: f32, scale: f32, color: Color) void {
        switch (api) {
            BackendApi.OpenGl => {
                renderer.gl_backend.?.drawText(text, x, y, scale, color);
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
                gl.RendererGl.clearBoundTexture();
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
