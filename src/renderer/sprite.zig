// Third Parties
const std = @import("std");
// dross-zig
const Color = @import("../core/color.zig").Color;
const Vector2 = @import("../core/vector2.zig").Vector2;
const tx = @import("texture.zig");
const TextureId = tx.TextureId;
const Texture = tx.Texture;
const rh = @import("../core/resource_handler.zig");

// -----------------------------------------
//      - Sprite -
// -----------------------------------------
pub const Sprite = struct {
    internal_texture: ?*Texture = undefined,
    internal_color: Color = undefined,
    /// The point of rotation on the sprite in pixels.
    internal_origin: Vector2 = undefined,
    internal_scale: Vector2 = undefined,
    internal_angle: f32 = 0.0,
    flip_h: bool = false,

    const Self = @This();

    /// Allocates and builds a Sprite
    /// Comments: The allocated Sprite will be owned by the caller, but the 
    /// allocated Texture is owned by the Resource Handler.
    pub fn new(allocator: *std.mem.Allocator, texture_name: []const u8, texture_path: []const u8) !*Self {
        var self = try allocator.create(Sprite);

        const texture_op = try rh.ResourceHandler.loadTexture(texture_name, texture_path);
        self.internal_texture = texture_op orelse return tx.TextureErrors.FailedToLoad;

        const texture_size = self.internal_texture.?.size();
        self.internal_color = Color.rgba(1.0, 1.0, 1.0, 1.0);
        // self.origin = texture_size.?.scale(0.5);
        self.internal_origin = Vector2.zero();
        self.internal_scale = Vector2.new(1.0, 1.0);
        self.internal_angle = 0.0;
        self.flip_h = false;

        return self;
    }

    /// Cleans up and de-allocates the Sprite
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        // Sprite is not the owner of texture, but has a reference to it is all.
        // Resource Handler is what owns all textures and will dispose of it.
        // It wouldn't make sense to unload a texture just because a single
        // Sprite instance was destroyed, unless that is the only reference of
        // the texture.
        allocator.destroy(self);
    }

    /// Returns the TextureId of the stored texture
    pub fn textureId(self: *Self) ?TextureId {
        if (self.internal_texture == undefined) return null;
        return self.internal_texture.?.id();
    }

    /// Sets the Sprites texture
    pub fn setTexture(self: *Self, new_texture: *Texture) void {
        self.internal_texture = new_texture;
    }

    /// Sets the Sprite color modulation
    pub fn setColor(self: *Self, new_color: Color) void {
        self.internal_color = new_color;
    }

    /// Returns the Sprite current color modulation
    pub fn color(self: *Self) Color {
        return self.internal_color;
    }

    /// Sets the Sprite scale
    pub fn setScale(self: *Self, new_scale: Vector2) void {
        self.internal_scale = new_scale;
    }

    /// Returns the Sprite's current scale as a Vector2
    pub fn scale(self: *Self) Vector2 {
        return self.internal_scale;
    }

    /// Returns the size of the Sprite's active texture
    pub fn size(self: *Self) ?Vector2 {
        if (self.internal_texture == undefined) return null;
        return self.internal_texture.?.size();
    }

    /// Returns the Sprite's origin
    pub fn origin(self: *Self) Vector2 {
        return self.internal_origin;
    }

    /// Sets the Sprite's origin
    /// Origin is in pixels, not percentage.
    pub fn setOrigin(self: *Self, new_origin: Vector2) void {
        self.internal_origin = new_origin;
    }

    /// Returns the Sprite's angle of rotation (in degrees)
    pub fn angle(self: *Self) f32 {
        return self.internal_angle;
    }

    /// Sets the Sprite's angle of rotation (in degrees)
    pub fn setAngle(self: *Self, new_angle: f32) void {
        self.internal_angle = new_angle;
    }

    /// Flags for the sprite's texture to be flipped horizontally
    pub fn setFlipH(self: *Self, value: bool) void {
        self.flip_h = value;
    }

    /// Returns whether the Sprite's texture has been flagged to be flipped horizontally
    pub fn flipH(self: *Self) bool {
        return self.flip_h;
    }
};
