// Third Parties
const std = @import("std");

// dross-zig
const Dross = @import("../dross_zig.zig");
usingnamespace Dross;
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - Player -
// -----------------------------------------

///
pub const Player = struct {
    //sprite: ?*Sprite = undefined,
    animator: ?*Animator2d = undefined,
    color: Color = undefined,
    scale: Vector2 = undefined,
    position: Vector3 = undefined,
    flip_h: bool = false,

    const Self = @This();

    /// Allocates and builds a player
    /// Comments: The caller will be the owner of the memory
    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var new_player = try allocator.create(Player);
        new_player.position = Vector3.new(0.0, 1.0, 0.0);
        new_player.scale = Vector2.new(1.0, 1.0);
        new_player.color = Color.white();
        new_player.flip_h = false;

        new_player.animator = try Animator2d.new(allocator);

        const texture_op = try ResourceHandler.loadTexture("player_ani", "assets/sprites/s_player_sheet.png");
        const texture_atlas = texture_op orelse return TextureErrors.FailedToLoad;

        var idle_animation: *Animation2d = undefined;
        var move_animation: *Animation2d = undefined;
        var jump_animation: *Animation2d = undefined;
        var climb_animation: *Animation2d = undefined;

        idle_animation = try Animation2d.new(allocator, "idle");
        move_animation = try Animation2d.new(allocator, "move");
        jump_animation = try Animation2d.new(allocator, "jump");
        climb_animation = try Animation2d.new(allocator, "climb");

        const idle_duration_array = [_]f32{0.25} ** 2;
        const move_duration_array = [_]f32{0.25} ** 4;
        const jump_duration_array = [_]f32{0.25} ** 1;
        const climb_duration_array = [_]f32{0.25} ** 4;

        const idle_rso_array = [_]Vector2{Vector2.new(1.0, 1.0)} ** 2;
        const move_rso_array = [_]Vector2{Vector2.new(1.0, 1.0)} ** 4;
        const jump_rso_array = [_]Vector2{Vector2.new(1.0, 1.0)} ** 1;
        const climb_rso_array = [_]Vector2{Vector2.new(1.0, 1.0)} ** 4;

        idle_animation.setLoop(true);
        move_animation.setLoop(true);
        jump_animation.setLoop(false);
        climb_animation.setLoop(true);

        try idle_animation.createFromTexture(
            texture_atlas,
            Vector2.new(0.0, 4.0), // Starting coordinates
            Vector2.new(16.0, 16.0), // Sprite Size
            2, // Number of frames/cells/regions
            idle_rso_array[0..],
            idle_duration_array[0..], // Frame durations
        );

        try move_animation.createFromTexture(
            texture_atlas,
            Vector2.new(0.0, 2.0), // Starting coordinates
            Vector2.new(16.0, 16.0), // Sprite Size
            4, // Number of frames/cells/regions
            move_rso_array[0..],
            move_duration_array[0..], // Frame durations
        );

        try jump_animation.createFromTexture(
            texture_atlas,
            Vector2.new(0.0, 3.0), // Starting coordinates
            Vector2.new(16.0, 16.0), // Sprite Size
            1, // Number of frames/cells/regions
            jump_rso_array[0..],
            jump_duration_array[0..], // Frame durations
        );

        try climb_animation.createFromTexture(
            texture_atlas,
            Vector2.new(0.0, 0.0), // Starting coordinates
            Vector2.new(16.0, 16.0), // Sprite Size
            4, // Number of frames/cells/regions
            climb_rso_array[0..],
            climb_duration_array[0..], // Frame durations
        );

        try new_player.animator.?.addAnimation(idle_animation);
        try new_player.animator.?.addAnimation(move_animation);
        try new_player.animator.?.addAnimation(jump_animation);
        try new_player.animator.?.addAnimation(climb_animation);

        new_player.animator.?.play("idle", false);

        return new_player;
    }

    /// Frees any allocated memory
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        Animator2d.free(allocator, self.animator.?);
        allocator.destroy(self);
    }

    /// Update logic
    pub fn update(self: *Self, delta: f32) void {
        const speed: f32 = 8.0 * delta;
        const movement_smoothing = 0.6;
        const input_horizontal = Input.keyPressedValue(DrossKey.KeyD) - Input.keyPressedValue(DrossKey.KeyA);
        const input_vertical = Input.keyPressedValue(DrossKey.KeyW) - Input.keyPressedValue(DrossKey.KeyS);
        const up = Input.keyReleased(DrossKey.KeyUp);
        const down = Input.keyReleased(DrossKey.KeyDown);

        const target_position = self.position.add( //
            Vector3.new( //
            input_horizontal * speed, //
            0.0, //
            0.0, //
        ));

        self.position = self.position.lerp(target_position, movement_smoothing);

        if (input_horizontal > 0.0 and self.flip_h) {
            // Negative scale
            self.flip_h = false;
        } else if (input_horizontal < 0.0 and !self.flip_h) {
            self.flip_h = true;
            // Positive scale
        }

        if (input_horizontal != 0.0) {
            self.animator.?.play("move", false);
        } else {
            self.animator.?.play("idle", false);
        }

        self.animator.?.update(delta);
    }

    /// Rendering event
    pub fn render(self: *Self) void {
        //Renderer.drawSprite(self.sprite.?, self.position);
        //if (!self.animator.?.playing()) return;
        const animation = self.animator.?.animation() orelse return;
        const frame = animation.textureRegion() orelse return;
        Renderer.drawTexturedQuad(frame, self.position, self.scale, self.color, self.flip_h);
    }
};
