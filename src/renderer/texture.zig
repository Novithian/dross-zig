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

/// dross-zig's container for image data
pub const Texture = struct {
    /// The internal texture 
    /// Comments: INTERNAL use only!
    gl_texture: ?*gl.OpenGlTexture,

    const Self = @This();

    /// Setups up the Texture and allocates and required memory
    fn build(self: *Self, allocator: *std.mem.Allocator) !void {
        switch (selected_api) {
            renderer.BackendApi.OpenGl => {
                self.gl_texture = try gl.buildOpenGlTexture(allocator);
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

    /// Returns the OpenGL generated texture ID
    pub fn getGlId(self: *Self) c_uint {
        return self.gl_texture.?.id;
    }
};

/// Allocates and builds a texture object depending on the target_api
/// Comments: The caller owns the Texture
pub fn buildTexture(allocator: *std.mem.Allocator) anyerror!*Texture {
    var texture: *Texture = try allocator.create(Texture);

    try texture.build(allocator);

    return texture;
}
