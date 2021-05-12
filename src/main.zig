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
const APP_WIDTH = 1280;
const APP_HEIGHT = 720;

//
var app: *Application = undefined;

var quad_position: Vector3 = undefined;
var quad_position_two: Vector3 = undefined;

var quad_texture: *Texture = undefined;
var quad_texture_two: *Texture = undefined;

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
    const guy_one_texture_op = try ResourceHandler.loadTexture("guy_idle", "assets/sprites/s_guy_idle.png");
    quad_texture = guy_one_texture_op orelse return error.FailedToLoadTexture; 

    const guy_two_texture_op = try ResourceHandler.loadTexture("enemy_01_idle", "assets/sprites/s_enemy_01_idle.png");
    quad_texture_two = guy_two_texture_op orelse return error.FailedToLoadTexture; 



    quad_position = Vector3.zero();
    quad_position_two = Vector3.new(1.0, 0.5, 1.0);

    // Begin the game loop
    app.*.run();

    return 0;
}
// Defined what game-level tick/update logic you want to control in the game.
pub export fn update(delta: f64) void {
    const delta32 = @floatCast(f32, delta);
    var input_horizontal = Input.getKeyPressedValue(DrossKey.KeyD) - Input.getKeyPressedValue(DrossKey.KeyA);
    var input_vertical = Input.getKeyPressedValue(DrossKey.KeyW) - Input.getKeyPressedValue(DrossKey.KeyS);

    quad_position = quad_position.add( //
        Vector3.new( //
        input_horizontal * delta32, //
        input_vertical * delta32, //
        0.0, //
    ));
}

pub export fn render() void {
    Renderer.drawTexturedQuad(quad_texture_two.*.getId(), quad_position_two);
    Renderer.drawTexturedQuad(quad_texture.*.getId(), quad_position);
}
