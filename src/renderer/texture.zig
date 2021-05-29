// Third Parties
const c = @import("../c_global.zig").c_imp;
const std = @import("std");
// dross-zig
const TextureGl = @import("backend/texture_opengl.zig").TextureGl;
const Color = @import("../core/color.zig").Color;
const renderer = @import("renderer.zig");
const selected_api = @import("renderer.zig").api;
const Vector2 = @import("../core/vector2.zig").Vector2;

// -----------------------------------------
//      - Texture -
// -----------------------------------------
/// Possible errors that may occur when dealing with Textures.
pub const TextureErrors = error{
    FailedToLoad,
};

pub const TextureId = union {
    id_gl: c_uint,
};

/// dross-zig's container for image data
pub const Texture = struct {
    /// The internal texture 
    /// Comments: INTERNAL use only!
    gl_texture: ?*TextureGl,
    /// The unique name of the texture
    internal_name: []const u8 = undefined,
    /// The ID for the texture,
    internal_id: TextureId,

    const Self = @This();

    /// Allocates and sets up a Texture
    /// Comments: The caller will own the allocated data, but
    /// this should be done through the Resource Handler. via
    /// loadTexture()
    pub fn new(allocator: *std.mem.Allocator, name: []const u8, path: []const u8) !*Self {
        var self = try allocator.create(Texture);

        switch (selected_api) {
            renderer.BackendApi.OpenGl => {
                self.gl_texture = TextureGl.new(allocator, path) catch |err| {
                    std.debug.print("{}\n", .{err});
                    @panic("[Texture]: ERROR when creating a texture!");
                };
                self.internal_id = .{
                    .id_gl = self.gl_texture.?.id(),
                };
                self.internal_name = name;
            },
            renderer.BackendApi.Dx12 => {},
            renderer.BackendApi.Vulkan => {},
        }

        return self;
    }

    /// Allocates and sets up a dataless Texture
    /// Comments: The caller will own the allocated data.
    pub fn newDataless(allocator: *std.mem.Allocator, desired_size: Vector2) !*Self {
        var self = try allocator.create(Texture);

        switch (selected_api) {
            renderer.BackendApi.OpenGl => {
                self.gl_texture = TextureGl.newDataless(allocator, desired_size) catch |err| {
                    std.debug.print("[Texture]: {}\n", .{err});
                    @panic("[Texture]: ERROR occurred when creating a dataless texture!");
                };
                self.internal_id = .{
                    .id_gl = self.gl_texture.?.id(),
                };
            },
            renderer.BackendApi.Dx12 => {},
            renderer.BackendApi.Vulkan => {},
        }

        return self;
    }

    /// Allocates and sets up a Texture for font-rendering
    /// Comments: The caller will own the allocated data, but
    /// this should be done through the Resource Handler via
    /// loadFont().
    pub fn newFont(allocator: *std.mem.Allocator, data: [*c]u8, width: u32, rows: u32) !*Self {
        var self = try allocator.create(Texture);

        switch (selected_api) {
            renderer.BackendApi.OpenGl => {
                self.gl_texture = TextureGl.newFont(allocator, data, width, rows) catch |err| {
                    std.debug.print("[Texture]: {}\n", .{err});
                    @panic("[Texture]: ERROR occurred when creating a font texture!");
                };
                self.internal_id = .{
                    .id_gl = self.gl_texture.?.id(),
                };
            },
            renderer.BackendApi.Dx12 => {},
            renderer.BackendApi.Vulkan => {},
        }

        return self;
    }

    /// Cleans up and de-allocates the Texture 
    /// Comments: Should only be called by the Resource Handler
    /// via unloadTexture()/unloadFont()
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        switch (selected_api) {
            renderer.BackendApi.OpenGl => {
                TextureGl.free(allocator, self.gl_texture.?);
            },
            renderer.BackendApi.Dx12 => {},
            renderer.BackendApi.Vulkan => {},
        }

        allocator.destroy(self);
    }

    /// Binds the texture
    pub fn bind(self: *Self) void {
        switch (selected_api) {
            renderer.BackendApi.OpenGl => {
                self.gl_texture.?.bind();
            },
            renderer.BackendApi.Dx12 => {},
            renderer.BackendApi.Vulkan => {},
        }
    }

    /// Returns the Texture ID
    pub fn id(self: *Self) TextureId {
        return self.internal_id;
    }

    /// Returns the OpenGL generated texture ID
    pub fn idGl(self: *Self) c_uint {
        return self.gl_texture.?.id();
    }

    /// Returns the size of the Texture
    pub fn size(self: *Self) ?Vector2 {
        switch (selected_api) {
            renderer.BackendApi.OpenGl => {
                const width: f32 = @intToFloat(f32, self.gl_texture.?.width());
                const height: f32 = @intToFloat(f32, self.gl_texture.?.height());
                return Vector2.new(width, height);
            },
            renderer.BackendApi.Dx12 => {
                return null;
            },
            renderer.BackendApi.Vulkan => {
                return null;
            },
        }
    }
};
