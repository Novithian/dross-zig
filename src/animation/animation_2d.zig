// Third Parties
const std = @import("std");
// dross-zig
const Vector2 = @import("../core/vector2.zig").Vector2;
const TextureRegion = @import("../renderer/texture_region.zig").TextureRegion;
const Frame2d = @import("frame_2d.zig").Frame2d;
const Math = @import("../math/math.zig").Math;

// -----------------------------------------
//      - Animation2D -
// -----------------------------------------

/// Animation2d bundles individual Frame2d instances and 
/// controls the flow of them.
pub const Animation2d = struct {
    /// The allocator required to populate the frames list.
    allocator: *std.mem.Allocator = undefined,
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
    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var self = try allocator.create(Animation2d);

        self.allocator = allocator;
        self.frames = std.ArrayList(*Frame2d).init(allocator);
        self.sit_on_final_frame = true;

        return self;
    }

    /// Cleans up and de-allocates the Animation2d. 
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        for (self.frames) |frame| {
            Frame2d.free(allocator, frame);
        }
        self.frames.deinit();
        allocator.destroy(self);
    }

    /// Appends a new frame to the Animation2d's frame list.
    pub fn addFrame(self: *Self, region: *TextureRegion, frame_duration: f32) !void {
        var new_frame = try Frame2d.new(self.allocator, region, frame_duration);

        self.frames.append(new_frame);
    }

    /// Begins the animation. If `force_restart` is true, then 
    /// the animation will restart from the beginning if it is 
    /// already playing.
    pub fn play(self: *Self, from_start: bool) void {
        if (self.animation_playing and from_start) {
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
    pub fn next(self: *Self) void {
        // Check to see if we're at the end of the animation
        if (self.current_frame + 1 >= self.frames.items.len) {
            self.onAnimationEnd();
            return;
        }

        // Increment the frame index
        self.current_frame = Math.clamp(self.current_frame + 1, 0, self.frames.items.len - 1);
    }

    /// Moves to the Animation2d's previous frame
    pub fn previous(self: *Self) void {
        // Check to see if we're at the start of the animation
        if (self.current_frame <= 0) {
            self.onAnimationEnd();
            return;
        }

        // Decrement the frame index
        self.current_frame = Math.clamp(self.current_frame - 1, 0, self.current_frame);
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
    pub fn setSitOnFinalFrame(self: *Self, bool: sit_on_final_frame) void {
        self.sit_on_final_frame = sit_on_final_frame;
    }

    /// Returns if the Animation2d is currently playing
    pub fn playing(self: *Self) bool {
        return self.animation_playing;
    }

    /// Returns the current frame index
    pub fn frameIndex(self: *Self) u16 {
        return self.current_frame;
    }

    /// Returns the current frame's TextureRegion
    pub fn textureRegion(self: *Self) *TextureRegion {
        return self.frames.items[self.current_frame];
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
};
