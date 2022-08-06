// Third Parties
const std = @import("std");
// dross-zig
const Vector2 = @import("../core/vector2.zig").Vector2;
const TextureRegion = @import("../renderer/texture_region.zig").TextureRegion;

// -----------------------------------------
//      - Frame2D -
// -----------------------------------------

/// Frame2d is a descriptor for a single frame of animation.
/// Containing the TextureRegion for the frame as well as
/// the duration the frame will run for. This allows for 
/// a more flexible animation system, rather than have
/// an entire animation run at a constant frame speed.
pub const Frame2d = struct {
    /// Sub-portion of the Texture Atlas/Spritesheet to be used as a single frame.
    frame_region: ?*TextureRegion = undefined,
    /// How long the frame will last
    frame_duration: f32 = 0.0,

    const Self = @This();

    /// Allocates and builds a new Frame2d instance.
    /// Comments: The caller will own the allocated memory.
    pub fn new(allocator: std.mem.Allocator, texture_region: *TextureRegion, frame_duration: f32) !*Self {
        var self = try allocator.create(Frame2d);

        self.frame_region = texture_region;
        self.frame_duration = frame_duration;

        return self;
    }

    /// Cleans up and de-allocates the Frame2d. The TextureRegion
    /// is not owned by the instance, so it will not need to be freed
    /// as it is only a reference.
    pub fn free(allocator: std.mem.Allocator, self: *Self) void {
        TextureRegion.free(allocator, self.frame_region.?);
        allocator.destroy(self);
    }

    /// Returns an optional pointer to the assigned TextureRegion.
    pub fn textureRegion(self: *Self) ?*TextureRegion {
        return self.frame_region;
    }

    /// Returns the assigned frame duration
    pub fn duration(self: *Self) f32 {
        return self.frame_duration;
    }
};
