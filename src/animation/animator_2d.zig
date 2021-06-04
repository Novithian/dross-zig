// Third Parties
const std = @import("std");
// dross-zig
const Vector2 = @import("../core/vector2.zig").Vector2;
const TextureRegion = @import("../renderer/texture_region.zig").TextureRegion;
const Frame2d = @import("frame_2d.zig").Frame2d;
const Animation2d = @import("animation_2d.zig").Animation2d;
const Renderer = @import("renderer.zig").Renderer;
const Math = @import("../math/math.zig").Math;

// -----------------------------------------
//      - Animator2d -
// -----------------------------------------

/// Animation2d bundles individual Frame2d instances and 
/// controls the flow of them.
pub const Animator2d = struct {
    /// Cache for the animations 
    animations: std.StringHashMap(*Animation2d) = undefined,
    /// The current animation
    current_animation: ?*Animation2d = undefined,
    /// The time when the frame began
    frame_timer: f32 = 0.0,
    /// The playback speed of the animation
    playback_speed: f32 = 1.0,
    /// If the animator is currently playing
    animation_playing: bool = false,

    const Self = @This();

    /// Allocates and builds a new Animation2d instance.
    /// Comments: The caller will own the allocated memory.
    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var self = try allocator.create(Animator2d);

        self.animations = std.StringHashMap(*Animation2d).init(allocator);
        self.current_animation = null;
        self.frame_timer = 0.0;
        self.playback_speed = 1.0;
        self.animation_playing = false;

        return self;
    }

    /// Cleans up and de-allocates the Animation2d. 
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        var iter = self.animations.iterator();
        while (iter.next()) |entry_animation| {
            Animation2d.free(allocator, entry_animation.value);
        }
        self.animations.deinit();
        allocator.destroy(self);
    }

    /// Update logic
    pub fn update(self: *Self, delta: f32) void {
        if (!self.animation_playing) return;

        const frame_duration = self.current_animation.?.frame().duration();

        if (self.frame_timer >= frame_duration) {
            // Go to next frame
            const end_of_animation = self.current_animation.?.next();
            if (end_of_animation) {
                self.current_animation.?.onAnimationEnd();
            }

            if (!self.current_animation.?.loop()) {
                self.stop();
            }

            self.reset();
        } else {
            self.frame_timer += delta;
        }
    }

    /// Appends a new Animation to the Animator2d's animation list.
    /// Comments: Ownership of the Animation2d is transferred to the 
    /// Animator2d.
    pub fn addAnimation(self: *Self, new_animation: *Animation2d) !void {
        // NOTE(devon): May be an issue with lifetime here
        try self.animations.put(new_animation.name(), new_animation);
    }

    /// Begins the animation. If `force_restart` is true, then 
    /// the animation will restart from the beginning if it is 
    /// already playing.
    pub fn play(self: *Self, animation_name: []const u8, force_restart: bool) void {
        if (self.animation_playing and !std.mem.eql(u8, animation_name, self.current_animation.?.name())) {
            self.current_animation.?.stop();
            self.current_animation.?.reset();
        }

        self.current_animation = self.animations.get(animation_name) orelse @panic("[Animator2D]: Requested animation does not exist!");

        self.current_animation.?.play(force_restart);

        self.animation_playing = true;
    }

    /// Stops the animation from playing, maintaining the current
    /// frame.
    pub fn stop(self: *Self) void {
        if (self.current_animation == undefined) return;
        self.current_animation.?.stop();
        self.animation_playing = false;
    }

    /// Resets  
    fn reset(self: *Self) void {
        self.frame_timer = 0.0;
    }

    /// Returns if the Animation2d is currently playing
    pub fn playing(self: *Self) bool {
        return self.animation_playing;
    }

    /// Returns the current Animation2d
    pub fn animation(self: *Self) ?*Animation2d {
        return self.current_animation;
    }
};
