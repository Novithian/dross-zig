const std = @import("std");
const dross_app = @import("core/application.zig");

// Comptime
const APP_TITLE = "Dross-Zig Application";
const APP_WIDTH = 640;
const APP_HEIGHT = 360;

pub fn main() anyerror!u8 {

    // create a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer {
        const leaked = gpa.deinit();
        if (leaked) @panic("[Dross-Application Name]: Memory leak detected!");
    }

    // Create the application
    var app: *dross_app.Application = dross_app.build(&gpa.allocator, APP_TITLE, APP_WIDTH, APP_HEIGHT) catch |err| {
        if (err == dross_app.ApplicationError.WindowCreation) {
            std.debug.print("[Application]Error: Failed to create window!\n", .{});
        } else if (err == dross_app.ApplicationError.RendererCreation) {
            std.debug.print("[Application]Error: Failed to create renderer!\n", .{});
        }
        // Exit program
        return 1;
    };

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
