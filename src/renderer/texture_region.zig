// Third Parties
const c = @import("../c_global.zig").c_imp;
const std = @import("std");
// dross-zig
const Texture = @import("texture.zig").Texture;
const Vector2 = @import("../core/vector2.zig").Vector2;

// -----------------------------------------
//      - TextureRegion -
// -----------------------------------------

/// A sub-portion of a texture to allow for the use of 
/// texture atlass/spritesheets.
pub const TextureRegion = struct {
    internal_texture: ?*Texture = undefined,
    texture_coordinates: [4]Vector2 = undefined,
    current_coordinates: Vector2 = undefined,
    region_size: Vector2 = undefined,
    number_of_regions: Vector2 = undefined,

    const Self = @This();

    /// Allocates and builds a new TextureRegion instance.
    /// Comments: The caller will own the TextureRegion, but 
    /// the texture passed is owned by the ResourceHandler.
    pub fn new(
        allocator: *std.mem.Allocator,
        atlas: *Texture, // The Texture Atlas to put a region from.
        coordinates: Vector2, // The region coordinates Ex: (1, 2) would be equal to (8, 16) if the region_size was 8x8.
        region_size: Vector2, // The size of the cell/region being sampled from. Ex: 16x16 region size on an atlas for a 16x16 sprite.
        number_of_regions: Vector2, // How many regions does the sprite occupy? Ex: 16x16 region size would need a number of regions(1, 2) for a 16x32 sprite.
    ) !*Self {
        var self = try allocator.create(TextureRegion);

        self.internal_texture = atlas;

        self.current_coordinates = coordinates;
        self.region_size = region_size;
        self.number_of_regions = number_of_regions;

        self.calculateTextureCoordinates();

        return self;
    }

    /// Cleans up and de-allocates the TextureRegion
    /// NOTE(devon): The referenced texture is owned by the
    /// ResourceHandler, so it will be freed by that system.
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        allocator.destroy(self);
    }

    /// Calculate the texture coordinates of the TextureRegion
    pub fn calculateTextureCoordinates(self: *Self) void {
        const region_w = self.region_size.x();
        const region_h = self.region_size.y();
        const coordinate_x = self.current_coordinates.x();
        const coordinate_y = self.current_coordinates.y();
        const texture_size = self.internal_texture.?.size();
        const texture_w = texture_size.?.x();
        const texture_h = texture_size.?.y();

        const min_coords = Vector2.new(
            (coordinate_x * region_w) / texture_w,
            (coordinate_y * region_h) / texture_h,
        );

        const max_coords = Vector2.new(
            ((coordinate_x + self.number_of_regions.x()) * region_w) / texture_w,
            ((coordinate_y + self.number_of_regions.y()) * region_h) / texture_h,
        );

        const min_x = min_coords.x();
        const min_y = min_coords.y();
        const max_x = max_coords.x();
        const max_y = max_coords.y();

        self.texture_coordinates = [4]Vector2{
            Vector2.new(min_x, min_y),
            Vector2.new(max_x, min_y),
            Vector2.new(max_x, max_y),
            Vector2.new(min_x, max_y),
        };
    }

    /// Sets the TextureRegion's atlas coordinates. 
    /// If `recalculate` is true, then it'll automatically
    /// recalculate the texture coordinates based on 
    /// the atlas coordinates.
    pub fn setAtlasCoordinates(self: *Self, new_coordinates: Vector2, recalculate: bool) void {
        // Check the bounds
        if (new_coordinates.x() < 0.0 or new_coordinates.y() < 0.0) return;
        const texture_size = self.internal_texture.?.size();
        if (new_coordinates.x() * self.region_size.x() >= texture_size.?.x() or
            new_coordinates.y() * self.region_size.y() >= texture_size.?.y()) return;

        self.current_coordinates = new_coordinates;

        if (recalculate) self.calculateTextureCoordinates();
    }

    /// Returns the assigned Texture Atlas
    pub fn texture(self: *Self) ?*Texture {
        return self.internal_texture;
    }

    /// Returns the assigned Texture Coordinates
    pub fn textureCoordinates(self: *Self) *[4]Vector2 {
        return &self.texture_coordinates;
    }

    /// Returns the current Atlas Coordinates
    pub fn atlasCoordinates(self: *Self) Vector2 {
        return self.current_coordinates;
    }
};
