const std = @import("std");
const Dross = @import("dross_zig.zig");
usingnamespace Dross;
// List of things the user will have to define:
//  - Create a allocator
//      var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//  - Defer the deinit if gpa
//      defer {
//          const leader = gpa.deinit();
//           if(leaked) @panic("mem leak");
//      }
//  - Create application
//      var app: *dross_app.Application = try dross_app.buildApplication(&gpa.allocator, "title", width, height);
//  - defer the allocator's free of the app
//      defer gpa.allocator.destroy(app)
//  - defer the app's free
//      defer app.*.free();
//  - Run the app loop
//      app.*.run();
//  - Define an update function
//      pub export fn update(delta: f64) void;

// Application Infomation
const APP_TITLE = "Dross-Zig Application";
const APP_WIDTH = 1280 ;
const APP_HEIGHT = 720;

//
var app: *Application = undefined;
var camera: *Camera2d = undefined;

var quad_position: Vector3 = undefined;
var quad_position_two: Vector3 = undefined;
var indicator_position: Vector3 = undefined;

var quad_sprite: *Sprite = undefined;
var quad_sprite_two: *Sprite = undefined;
var indicator_sprite: *Sprite = undefined;

pub fn main() anyerror!u8 {

    // create a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer {
        const leaked = gpa.deinit();
        if (leaked) @panic("[Dross-Application Name]: Memory leak detected!");
    }

    // Create the application
    app = try buildApplication(
        &gpa.allocator,
        APP_TITLE,
        APP_WIDTH,
        APP_HEIGHT,
    );

    // Clean up the allocated application before exiting
    defer gpa.allocator.destroy(app);

    // NOTE(devon): Defer executes in the opposite order of the
    // calls, so app.free will be executed before allocator.destroy
    // Tells the program to free the app before exiting for
    // proper clean-up.
    defer app.*.free();

    // Setup
    const camera_op = getCurrentCamera();
    camera = camera_op orelse return CameraError.CameraNotFound;

    quad_sprite = try buildSprite(&gpa.allocator, "guy_idle", "assets/sprites/s_guy_idle.png");
    quad_sprite_two = try buildSprite(&gpa.allocator, "enemy_01_idle", "assets/sprites/s_enemy_01_idle.png");
    indicator_sprite = try buildSprite(&gpa.allocator, "indicator", "assets/sprites/s_ui_indicator.png");

    // quad_sprite_two.*.setOrigin(Vector2.new(7.0, 14.0));
    indicator_sprite.*.setOrigin(Vector2.new(8.0, 11.0));
    // indicator_sprite.*.setAngle(30.0);

    defer gpa.allocator.destroy(quad_sprite);
    defer gpa.allocator.destroy(quad_sprite_two);
    defer gpa.allocator.destroy(indicator_sprite);

    defer quad_sprite.*.free(&gpa.allocator);
    defer quad_sprite_two.*.free(&gpa.allocator);
    defer indicator_sprite.*.free(&gpa.allocator);
    

    quad_position = Vector3.zero();
    quad_position_two = Vector3.new(2.0, 0.0, 1.0);
    indicator_position = Vector3.new(-2.0, 0.0, -1.0);

    // Begin the game loop
    app.*.run();

    return 0;
}
// Defined what game-level tick/update logic you want to control in the game.
pub export fn update(delta: f64) void {
    const delta32 = @floatCast(f32, delta);
    const speed: f32 = 8.0 * delta32;
    const rotational_speed = 100.0 * delta32;
    const movement_smoothing = 0.6;
    var input_horizontal = Input.getKeyPressedValue(DrossKey.KeyD) - Input.getKeyPressedValue(DrossKey.KeyA);
    var input_vertical = Input.getKeyPressedValue(DrossKey.KeyW) - Input.getKeyPressedValue(DrossKey.KeyS);

    const target_position =quad_position.add( //
        Vector3.new( //
        input_horizontal * speed, //
        input_vertical * speed, //
        0.0, //
    ));

    quad_position = quad_position.lerp(target_position, movement_smoothing);
    

    // const quad_old_angle = quad_sprite_two.*.getAngle();
    // const indicator_old_angle = indicator_sprite.*.getAngle();

    // // quad_sprite_two.setAngle(quad_old_angle + rotational_speed);
    // // indicator_sprite.setAngle(indicator_old_angle + rotational_speed);

    // const window_size = Application.getWindowSize();
    // const zoom = camera.*.getZoom();
    // const old_camera_position = camera.*.getPosition();
    // const camera_smoothing = 0.075;

    // const new_camera_position = Vector3.new(    
    //     lerp(old_camera_position.getX(), -quad_position.getX(), camera_smoothing), 
    //     lerp(old_camera_position.getY(), -quad_position.getY(), camera_smoothing), 
    //     0.0,
    // );
    // camera.*.setPosition(new_camera_position);
}

pub export fn render() void {
    Renderer.drawSprite(quad_sprite, quad_position);
    Renderer.drawSprite(quad_sprite_two, quad_position_two);
    Renderer.drawSprite(indicator_sprite, indicator_position);
}
