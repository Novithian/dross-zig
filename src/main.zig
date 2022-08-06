// Third-Party
const std = @import("std");
// Dross-zig
const Dross = @import("dross_zig.zig");
const Player = @import("sandbox/player.zig").Player;
// -------------------------------------------

// Application Infomation
const APP_TITLE = "Dross-Zig Application";
const APP_WINDOW_WIDTH = 1280;
const APP_WINDOW_HEIGHT = 720;
const APP_VIEWPORT_WIDTH = 320;
const APP_VIEWPORT_HEIGHT = 180;

// Application related
var app: *Dross.Application = undefined;
var allocator: std.mem.Allocator = undefined;

// Gameplay related
var camera: *Dross.Camera2d = undefined;

var player: *Player = undefined;

var quad_position_two: Dross.Vector3 = undefined;
var indicator_position: Dross.Vector3 = undefined;

var quad_sprite_two: *Dross.Sprite = undefined;
var indicator_sprite: *Dross.Sprite = undefined;
var sprite_sheet_example: *Dross.Sprite = undefined;

// Colors
const background_color: Dross.Color = .{
    .r = 0.27843,
    .g = 0.27843,
    .b = 0.27843,
};

const ground_color: Dross.Color = .{
    .r = 0.08235,
    .g = 0.12157,
    .b = 0.14510,
    .a = 1.0,
};

const white: Dross.Color = .{
    .r = 1.0,
    .g = 1.0,
    .b = 1.0,
};

//const ground_color: Color = .{
//    .r = 0.58431,
//    .g = 0.47834,
//    .b = 0.36471,
//};

const ground_position: Dross.Vector3 = Dross.Vector3.new(0.0, 0.0, 0.0);
const ground_scale: Dross.Vector3 = Dross.Vector3.new(20.0, 1.0, 0.0);
const indentity_scale: Dross.Vector3 = Dross.Vector3.new(1.0, 1.0, 0.0);

const max_random = 20.0;
const random_count = 8000.0;
var random_positions: []Dross.Vector3 = undefined;
var random_colors: []Dross.Color = undefined;

pub fn main() anyerror!u8 {

    // create a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        if (leaked) @panic("[Dross-Application Name]: Memory leak detected!");
    }

    // Create test audio engine
    //var audio_engine = try Dross.AudioEngine.create(allocator);
    //defer audio_engine.destroy();

    //audio_engine.setVolume(0.15);

    //try audio_engine.playOneShot("assets/audio/sfx/test_sfx.wav");

    // Create the application
    app = try Dross.Application.new(
        allocator,
        APP_TITLE,
        APP_WINDOW_WIDTH,
        APP_WINDOW_HEIGHT,
        APP_VIEWPORT_WIDTH,
        APP_VIEWPORT_HEIGHT,
    );

    // Clean up the allocated application before exiting
    defer Dross.Application.free(allocator, app);

    // Setup
    camera = try Dross.Camera2d.new(allocator);
    defer Dross.Camera2d.free(allocator, camera);

    player = try Player.new(allocator);

    quad_sprite_two = try Dross.Sprite.new(allocator, "enemy_01_idle", "assets/sprites/s_enemy_01_idle.png", Dross.Vector2.zero(), Dross.Vector2.new(16.0, 16.0), Dross.Vector2.new(1.0, 1.0));
    indicator_sprite = try Dross.Sprite.new(allocator, "indicator", "assets/sprites/s_ui_indicator.png", Dross.Vector2.zero(), Dross.Vector2.new(16.0, 16.0), Dross.Vector2.new(1.0, 1.0));

    //quad_sprite_two.*.setOrigin(Vector2.new(7.0, 14.0));
    //indicator_sprite.*.setOrigin(Vector2.new(8.0, 11.0));
    //indicator_sprite.*.setAngle(30.0);

    defer Player.free(allocator, player);
    defer Dross.Sprite.free(allocator, quad_sprite_two);
    defer Dross.Sprite.free(allocator, indicator_sprite);

    quad_position_two = Dross.Vector3.new(2.0, 1.0, 1.0);
    indicator_position = Dross.Vector3.new(5.0, 1.0, -1.0);

    Dross.Renderer.changeClearColor(background_color);

    var random_positions_arr: [random_count]Dross.Vector3 = undefined;
    var random_colors_arr: [random_count]Dross.Color = undefined;

    var count: usize = random_count;
    var index: usize = 0;

    while (index < count) : (index += 1) {
        random_positions_arr[index] = try Dross.Vector3.random(max_random);
        random_colors_arr[index] = try Dross.Color.random();
    }

    random_positions = random_positions_arr[0..];
    random_colors = random_colors_arr[0..];

    // Begin the game loop
    app.run(update, render, gui_render);

    return 0;
}

/// Defines what game-level tick/update logic you want to control in the game.
pub fn update(delta: f64) anyerror!void {
    const delta32 = @floatCast(f32, delta);
    //const speed: f32 = 8.0 * delta32;
    //const rotational_speed = 100.0 * delta32;
    //const scale_speed = 10.0 * delta32;
    // const max_scale = 5.0;
    // const movement_smoothing = 0.6;

    player.update(delta32);

    //const quad_old_scale = quad_sprite_two.*.scale();
    //const indicator_old_angle = indicator_sprite.*.angle();

    //indicator_sprite.setAngle(indicator_old_angle + rotational_speed);

    // const window_size = Application.windowSize();
    // const zoom = camera.*.zoom();
    // const old_camera_position = camera.*.position();
    // const camera_smoothing = 0.075;

    // const new_camera_position = Vector3.new(
    //     Math.lerp(old_camera_position.x(), -quad_position.x(), camera_smoothing),
    //     Math.lerp(old_camera_position.y(), -quad_position.y(), camera_smoothing),
    //     0.0,
    // );
    // camera.*.setPosition(new_camera_position);

}

/// Defines the game-level rendering
pub fn render() anyerror!void {
    player.render();
    Dross.Renderer.drawSprite(quad_sprite_two, quad_position_two);
    Dross.Renderer.drawSprite(indicator_sprite, indicator_position);
    Dross.Renderer.drawColoredQuad(ground_position, ground_scale, ground_color);
    //Renderer.drawColoredQuad(player.position, indentity_scale, ground_color);
    //Renderer.drawColoredQuad(indicator_position, indentity_scale, ground_color);
    //Renderer.drawColoredQuad(quad_position_two, indentity_scale, ground_color);

    //var count: usize = random_count;
    //var index: usize = 0;

    //while (index < count) : (index += 1) {
    //    Renderer.drawColoredQuad(random_positions[index], indentity_scale, random_colors[index]);
    //}
}

/// Defines the game-level gui rendering
pub fn gui_render() anyerror!void {
    //const user_message: []const u8 = "[Application-requested render] ";
    //const ass_string: []const u8 = "Eat Ass, ";
    //const skate_string: []const u8 = "Skate Fast";

    //const user_width = getStringWidth(user_message, 1.0);
    //const user_height = getStringHeight(user_message, 1.0);
    //const ass_width = getStringWidth(ass_string, 1.0);

    //Renderer.drawText(user_message, 5.0, 5.0, 1.0, white);
    //Renderer.drawText(ass_string, 5.0, 5.0 + user_height, 1.0, white);
    //Renderer.drawText(skate_string, 5.0 + ass_width, 5.0 + user_height, 1.0, white);

    //const stupid_message: []const u8 = "I want to run a test to see how many textured quads it'll take to slow this down.";

    //const stupid_height = getStringHeight(stupid_message, 1.0);

    //const count: usize = 20;
    //var index: usize = 0;

    //while (index < count) : (index += 1) {
    //    Renderer.drawText(stupid_message, 5.0, 5.0 + (stupid_height * @intToFloat(f32, index)), 1.0, white);
    //}
}
