// Third Parties
const std = @import("std");
// dross-zig
const Vector2 = @import("../core/vector2.zig").Vector2;
const TextureRegion = @import("../renderer/texture_region.zig").TextureRegion;
const Texture = @import("../renderer/texture.zig").Texture;
const Frame2d = @import("frame_2d.zig").Frame2d;
const Math = @import("../math/math.zig").Math;

// -----------------------------------------
//      - Animation2D -
// -----------------------------------------

/// Animation2d bundles individual Frame2d instances and 
/// controls the flow of them.
pub const Animation2d = struct {
    /// The allocator required to populate the frames list.
    allocator: std.mem.Allocator = undefined,
    /// The name of the animation
    animation_name: []const u8 = undefined,
    /// Cache for the frames used in the animation
    frames: std.ArrayList(*Frame2d) = undefined,
    /// The current frame
    current_frame: u16 = 0,
    /// Flag to control if the animation should be looped or not
    /// Default: true
    loop_animation: bool = true,
    /// Is the animation currently playing
    animation_playing: bool = false,
    /// Determines if the animation will sit on the last frame or 
    /// the first frame if the animation does NOT loop.
    sit_on_final_frame: bool = true,

    const Self = @This();

    /// Allocates and builds a new Animation2d instance.
    /// Comments: The caller will own the allocated memory.
    pub fn new(allocator: std.mem.Allocator, animation_name: []const u8) !*Self {
        var self = try allocator.create(Animation2d);

        self.allocator = allocator;
        self.animation_name = animation_name;
        self.frames = std.ArrayList(*Frame2d).init(allocator);
        self.current_frame = 0;
        self.loop_animation = true;
        self.animation_playing = false;
        self.sit_on_final_frame = true;

        return self;
    }

    /// Cleans up and de-allocates the Animation2d. 
    pub fn free(allocator: std.mem.Allocator, self: *Self) void {
        for (self.frames.items) |animation_frame| {
            Frame2d.free(allocator, animation_frame);
        }

        self.frames.deinit();
        allocator.destroy(self);
    }

    /// Creates and adds the Animation2d's frames
    /// Comments: The Animation2d will owe the allocated memory.
    pub fn createFromTexture(
        self: *Self,
        texture_atlas: *Texture,
        start_coordinate: Vector2,
        region_size: Vector2, // i.e: 16x16 grid
        comptime region_count: u16, // The number of frames/cells/regions to extract
        comptime regions_sprite_occupies: []const Vector2, // e.x.: a 16x32 sprite on a 16x16 grid will have need Vector2(1.0, 2.0).
        comptime frame_durations: []const f32,
    ) !void {

        // Check to see if the length of frame_durations slice and regions_sprite_occupies
        // slice matches the region_count
        if (region_count != regions_sprite_occupies.len or region_count != frame_durations.len) {
            std.debug.print("{} | {} | {}\n", .{ region_count, regions_sprite_occupies.len, frame_durations.len });
            @compileError("[Animation2D]: Region count, length of the slice the regions the sprite occupies, and length of the slice of frame durations MUST be uniform!");
        }

        // Loop the number of regions
        var index: usize = 0;

        while (index < region_count) : (index += 1) {
            // Create the TextureRegion

            const frame_coordinate = start_coordinate.add(
                Vector2.new(@intToFloat(f32, index), 0.0),
            );

            var frame_region = try TextureRegion.new(
                self.allocator,
                texture_atlas,
                frame_coordinate,
                region_size,
                regions_sprite_occupies[index],
            );

            // Add Frame2d to animation
            try self.addFrame(frame_region, frame_durations[index]);
        }
    }

    /// Appends a new frame to the Animation2d's frame list.
    pub fn addFrame(self: *Self, region: *TextureRegion, frame_duration: f32) !void {
        var new_frame = try Frame2d.new(self.allocator, region, frame_duration);

        try self.frames.append(new_frame);
    }

    /// Begins the animation. If `force_restart` is true, then 
    /// the animation will restart from the beginning if it is 
    /// already playing.
    pub fn play(self: *Self, force_restart: bool) void {
        if (self.animation_playing and force_restart) {
            self.reset();
        }

        if (self.animation_playing) return;

        self.animation_playing = true;
    }

    /// Stops the animation from playing, maintaining the current
    /// frame.
    pub fn stop(self: *Self) void {
        self.animation_playing = false;
    }

    /// Resets the animation from the beginnning
    pub fn reset(self: *Self) void {
        self.current_frame = 0;
    }

    /// Moves to the Animation2d's next frame
    /// Returns true if the animation is over
    pub fn next(self: *Self) bool {
        // Check to see if we're at the end of the animation
        if (self.current_frame + 1 >= self.frames.items.len) {
            //self.onAnimationEnd();
            return true;
        }

        // Increment the frame index
        const target_value: u16 = self.current_frame + 1;
        const min_value: u16 = 0;
        const max_value: u16 = @intCast(u16, self.frames.items.len) - 1;
        self.current_frame = Math.clamp(target_value, min_value, max_value);

        return false;
    }

    /// Moves to the Animation2d's previous frame
    /// Returns true if the animation is over
    pub fn previous(self: *Self) bool {
        // Check to see if we're at the start of the animation
        if (self.current_frame <= 0) {
            //self.onAnimationEnd();
            return true;
        }

        // Decrement the frame index
        self.current_frame = Math.clamp(self.current_frame - 1, 0, self.current_frame);

        return false;
    }

    /// Called when the animation has completed. 
    pub fn onAnimationEnd(self: *Self) void {
        // TODO(devon): Send messsage to observers when events are implemented

        // Loops the animation
        if (self.loop_animation) {
            self.reset();
            return;
        }

        self.animation_playing = false;

        // Reset to the first frame
        if (!self.sit_on_final_frame) {
            self.reset();
        }
    }

    /// Sets the loop flag that tells the Animation2d to loop the animation when it completes.
    pub fn setLoop(self: *Self, loop_animation: bool) void {
        self.loop_animation = loop_animation;
    }

    /// Sets the flag that tells the Animation2d what frame to remain on,  
    /// final frame (if the animation does NOT loop), or the 
    /// first frame.
    pub fn setSitOnFinalFrame(self: *Self, sit_on_final_frame: bool) void {
        self.sit_on_final_frame = sit_on_final_frame;
    }

    /// Returns if the Animation2d is currently playing
    pub fn playing(self: *Self) bool {
        return self.animation_playing;
    }

    /// Returns the current Frame2d
    pub fn frame(self: *Self) *Frame2d {
        return self.frames.items[self.current_frame];
    }

    /// Returns the current frame index
    pub fn frameIndex(self: *Self) u16 {
        return self.current_frame;
    }

    /// Returns the current frame's TextureRegion
    pub fn textureRegion(self: *Self) ?*TextureRegion {
        return self.frames.items[self.current_frame].textureRegion();
    }

    /// Returns whether the Animation2d is set to loop.
    pub fn loop(self: *Self) bool {
        return self.loop_animation;
    }

    /// Returns whether the Animation2d will remain the the 
    /// final frame (if the animation does NOT loop), or the 
    /// first frame.
    pub fn sitOnFinalFrame(self: *Self) bool {
        return self.sit_on_final_frame;
    }

    /// Returns the given name of the animation
    pub fn name(self: *Self) []const u8 {
        return self.animation_name;
    }
};
