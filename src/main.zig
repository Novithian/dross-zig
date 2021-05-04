const std = @import("std");
const dross_app = @import("core/application.zig");

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

// Comptime
const APP_TITLE = "Dross-Zig Application";
const APP_WIDTH = 1280;
const APP_HEIGHT = 720;

var app: *dross_app.Application = undefined;

pub fn main() anyerror!u8 {

    // create a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer {
        const leaked = gpa.deinit();
        if (leaked) @panic("[Dross-Application Name]: Memory leak detected!");
    }

    // Create the application
    app = try dross_app.buildApplication(
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

    // Begin the game loop
    app.*.run();

    return 0;
}

/// Defined what game-level tick/update logic you want to control in the game.
pub export fn update(delta: f64) void {}
