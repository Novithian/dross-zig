// Third Parties
const c = @import("../c_global.zig").c_imp;
const std = @import("std");
// dross-zig
const gl = @import("backend/texture_opengl.zig");
const Color = @import("../core/core.zig").Color;
const renderer = @import("renderer.zig");
const selected_api = @import("renderer.zig").api;

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
    gl_texture: ?*gl.OpenGlTexture,
    /// The unique name of the texture
    name: []const u8 = undefined,
    /// The ID for the texture,
    id: TextureId,

    const Self = @This();

    /// Setups up the Texture and allocates and required memory
    fn build(self: *Self, allocator: *std.mem.Allocator, name: []const u8, path: []const u8) !void {
        switch (selected_api) {
            renderer.BackendApi.OpenGl => {
                self.gl_texture = gl.buildOpenGlTexture(allocator, path) catch |err| {
                    std.debug.print("{}\n", .{err});
                    @panic("[Texture]: ERROR when creating a texture!");
                };
                self.id = .{
                    .id_gl = self.gl_texture.?.getId(),
                };
                self.name = name;
            },
            renderer.BackendApi.Dx12 => {},
            renderer.BackendApi.Vulkan => {},
        }
    }

    /// Deallocates any owned memory that was required for operation
    pub fn free(self: *Self, allocator: *std.mem.Allocator) void {
        switch (selected_api) {
            renderer.BackendApi.OpenGl => {
                self.gl_texture.?.free(allocator);
                allocator.destroy(self.gl_texture.?);
            },
            renderer.BackendApi.Dx12 => {},
            renderer.BackendApi.Vulkan => {},
        }
    }

    /// Returns the Texture ID
    pub fn getId(self: *Self) TextureId {
        return self.id;
    }

    /// Returns the OpenGL generated texture ID
    pub fn getGlId(self: *Self) c_uint {
        return self.gl_texture.?.getId();
    }
};

/// Allocates and builds a texture object depending on the target_api
/// Comments: The caller owns the Texture
/// INTERNAL USE ONLY.
pub fn buildTexture(allocator: *std.mem.Allocator, name: []const u8, path: []const u8) anyerror!*Texture {
    var texture: *Texture = try allocator.create(Texture);

    try texture.build(allocator, name, path);

    return texture;
}
