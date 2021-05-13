// Third Parties
const std = @import("std");
// dross-zig
const Color = @import("../core/core.zig").Color;
const Vector2 = @import("../core/vector2.zig").Vector2;
const tx = @import("texture.zig");
const Texture = tx.Texture;
const rh = @import("../core/resource_handler.zig");

// -----------------------------------------
//      - Sprite -
// -----------------------------------------
pub const Sprite = struct {
    texture: ?*Texture = undefined,
    color: Color = undefined,
    /// The point of rotation on the sprite in pixels.
    origin: Vector2 = undefined,
    scale: Vector2 = undefined,
    angle: f32 = 0.0,

    const Self = @This();

    /// Builds the Sprite and allocates the required memory
    pub fn build(self: *Self, texture_name: []const u8, texture_path: []const u8) !void {
        const texture_op = try rh.ResourceHandler.loadTexture(texture_name, texture_path);
        self.texture = texture_op orelse return tx.TextureErrors.FailedToLoad;

        const texture_size = self.texture.?.getSize();
        self.color = Color.rgba(1.0, 1.0, 1.0, 1.0);
        // self.origin = texture_size.?.scale(0.5);
        self.origin = Vector2.zero();
        self.scale = Vector2.new(1.0, 1.0);
        self.angle = 0.0;
    }

    /// Frees the Sprite
    pub fn free(self: *Self, allocator: *std.mem.Allocator) void {
        // Sprite is not the owner of texture, but has a reference to it is all.
        // Resource Handler is what owns all textures and will dispose of it.
        // It wouldn't make sense to unload a texture just because a single 
        // Sprite instance was destroyed, unless that is the only reference of
        // the texture.
    }

    /// Returns the TextureId of the stored texture
    pub fn getTextureId(self: *Self) ?tx.TextureId {
        if(self.texture == undefined) return null;
        return self.texture.?.getId();
    }

    /// Sets the Sprites texture
    pub fn setTexture(self: *Self, new_texture: *Texture) void {
        self.texture = new_texture;
    }

    /// Sets the Sprite color modulation
    pub fn setColor(self: *Self, new_color: Color) void {
        self.color = new_color;
    }

    /// Returns the Sprite current color modulation
    pub fn getColor(self: *Self) Color {
        return self.color;
    }

    /// Sets the Sprite scale
    pub fn setScale(self: *Self, new_scale: Vector2) void {
        self.scale = new_scale;
    }

    /// Returns the Sprite's current scale as a Vector2
    pub fn getScale(self: *Self) Vector2 {
        return self.scale;
    }

    /// Returns the size of the Sprite's active texture
    pub fn getSize(self: *Self) ?Vector2 {
        if(self.texture == undefined) return null;
        return self.texture.?.getSize();
    }

    /// Returns the Sprite's origin
    pub fn getOrigin(self: *Self) Vector2 {
        return self.origin;
    }

    /// Sets the Sprite's origin
    /// Origin is in pixels, not percentage.
    pub fn setOrigin(self: *Self, new_origin: Vector2) void {
        self.origin = new_origin;
    }

    /// Returns the Sprite's angle of rotation (in degrees)
    pub fn getAngle(self: *Self) f32 {
        return self.angle;
    }

    /// Sets the Sprite's angle of rotation (in degrees)
    pub fn setAngle(self: *Self, new_angle: f32) void {
        self.angle = new_angle;
    }
};

/// Allocates and builds the Sprite
/// Comments: The allocated Sprite will be owned by the caller, but the 
/// allocated Texture is owned by the Resource Handler.
pub fn buildSprite(allocator: *std.mem.Allocator, texture_name: []const u8, texture_path: []const u8) !*Sprite{
    var sprite: *Sprite = try allocator.create(Sprite);

    try sprite.build(texture_name, texture_path);

    return sprite;

}