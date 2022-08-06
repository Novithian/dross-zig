// Third-Party
const c = @import("../c_global.zig").c_imp;
const std = @import("std");
// dross-zig
//const Timer = @import("../utils/timer.zig").Timer;
const ResourceHandler = @import("resource_handler.zig").ResourceHandler;
const Renderer = @import("../renderer/renderer.zig").Renderer;
const font = @import("../renderer/font/font.zig");
const Font = font.Font;
const cam = @import("../renderer/cameras/camera_2d.zig");
const Vector2 = @import("../core/vector2.zig").Vector2;
const Vector3 = @import("../core/vector3.zig").Vector3;
const input = @import("input.zig");
const Input = input.Input;
const DrossKey = input.DrossKey;
const DrossMouseButton = input.DrossMouseButton;
const FrameStatistics = @import("../utils/profiling/frame_statistics.zig").FrameStatistics;
// ----------------------------------------------------

/// Error Set for Application-related Errors
pub const ApplicationError = error{
    OutOfMemory,
    RendererCreation,
    WindowCreation,
    WindowInit,
};

/// TODO(devon): Remove when shipping
pub var debug_mode = false;
pub var pause = false;
pub var default_font: ?*Font = undefined;

/// Stores the current size of the window
var window_size: Vector2 = undefined;

/// Stores the window to allow other systems
/// to communicate with it without needing a 
/// Application instance.
var app_window: *c.GLFWwindow = undefined;

/// Stores the application's viewport size
var viewport_size: Vector2 = undefined;

// -----------------------------------------
//      - Application -
// -----------------------------------------

/// Application is the center point of the entire program.
/// Most of the communication from the end-user will come
/// through the application instance.
pub const Application = struct {
    allocator: ?std.mem.Allocator = undefined,
    previous_frame_time: f64 = 0,

    const Self = @This();

    /// Allocates the necessary components to run the application
    /// Comments: The caller will be the owner of the returned pointer, but
    /// any other required allocated memory will be owned by the engine.
    pub fn new(allocator: std.mem.Allocator, title: [*c]const u8, width: c_int, height: c_int, vp_width: f32, vp_height: f32) anyerror!*Self {
        var self = try allocator.create(Application);

        // Initialze GLFW, returns GL_FALSE if an error occured.
        if (c.glfwInit() == c.GL_FALSE) return ApplicationError.WindowInit;

        // GLFW Configuration
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 5);
        c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
        c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);

        // Window Creation
        app_window = c.glfwCreateWindow(width, height, title, null, null) orelse return ApplicationError.WindowCreation;

        // Set the global variables
        window_size = Vector2.new(
            @intToFloat(f32, width),
            @intToFloat(f32, height),
        );

        // Set the viewport size
        viewport_size = Vector2.new(vp_width, vp_height);

        // Make our window the current context
        c.glfwMakeContextCurrent(app_window);

        // Change the wait time for swapping buffers 0
        // TODO(devon): Remove when shipping
        c.glfwSwapInterval(0);

        // Build the Resource Hanlder
        ResourceHandler.new(allocator);

        // Build the Renderer
        try Renderer.new(allocator);

        // Remember to set the app's allocator to the passed allocator
        self.allocator = allocator;

        _ = c.glfwSetFramebufferSizeCallback(app_window, Renderer.resizeInternal);

        // Resize the application's viewport to match that of the window
        // self.resize(0, 0, width, height);

        // Build the rest of the core components of an application
        //
        try Input.new(allocator);

        try FrameStatistics.new(allocator);

        default_font = ResourceHandler.loadFont("Ubuntu Mono", "assets/fonts/ttf/UbuntuMono.ttf") orelse null;

        return self;
    }

    /// Gracefully terminates the Application by cleaning up
    /// manually allocated memory as well as some other backend
    /// cleanup.
    /// Comments: Be sure to call before exiting program!    
    pub fn free(allocator: std.mem.Allocator, self: *Self) void {
        c.glfwDestroyWindow(app_window);
        c.glfwTerminate();

        // Manually allocated memory cleanup
        FrameStatistics.free(self.allocator.?);
        Input.free(self.allocator.?);
        Renderer.free(self.allocator.?);
        ResourceHandler.free();

        allocator.destroy(self);
    }

    /// Runs the applications main event loop. 
    pub fn run(
        self: *Self,
        update_loop: fn (f64) anyerror!void,
        render_loop: fn () anyerror!void,
        gui_render_loop: fn () anyerror!void,
    ) void {

        // Pre-run checks
        if (cam.cameraCount() <= 0) {
            std.debug.print("[Application]: No camera could be found in the scene!\n", .{});
            @panic("[Application]: Error occurred before starting the application loop!\n");
        }

        while (c.glfwWindowShouldClose(app_window) == 0) {
            // Profiling
            var frame_timer = std.time.Timer.start() catch |err| {
                std.debug.print("[Application]: Error occurred when creating a timer! {}\n", .{err});
                @panic("[Application]: Error occurred creating a timer!\n");
            };

            var frame_duration: f64 = -1.0;
            var update_duration: f64 = -1.0;
            var draw_duration: f64 = -1.0;

            // Calculate timestep
            const current_time = c.glfwGetTime();
            var delta = current_time - self.previous_frame_time;
            self.previous_frame_time = current_time;

            //// TODO(devon): Remove when shipping
            if (debug_mode and pause) delta = 0;

            //// Process input
            self.processInput(delta);

            { // Update
                var update_timer = std.time.Timer.start() catch |err| {
                    std.debug.print("[Application]: Error occurred when creating a timer! {}\n", .{err});
                    @panic("[Application]: Error occurred creating a timer!\n");
                };

                _ = update_loop(delta) catch |err| {
                    std.debug.print("[Application]: Update loop encountered an error! {}\n", .{err});
                    @panic("[Application]: Error occurred during the update loop!\n");
                };

                update_duration = @intToFloat(f64, update_timer.read()) / @intToFloat(f64, std.time.ns_per_ms);
            }

            { // Render
                var draw_timer = std.time.Timer.start() catch |err| {
                    std.debug.print("[Application]: Error occurred when creating a timer! {}\n", .{err});
                    @panic("[Application]: Error occurred creating a timer!\n");
                };

                Renderer.render(render_loop, gui_render_loop);

                draw_duration = @intToFloat(f64, draw_timer.read()) / @intToFloat(f64, std.time.ns_per_ms);
            }

            // Submit
            c.glfwSwapBuffers(app_window);
            Input.updateInput();
            c.glfwPollEvents();

            frame_duration = @intToFloat(f64, frame_timer.read()) / @intToFloat(f64, std.time.ns_per_ms);

            FrameStatistics.setFrameTime(frame_duration);
            FrameStatistics.setUpdateTime(update_duration);
            FrameStatistics.setDrawTime(draw_duration);
            FrameStatistics.reset();
        }
    }

    /// Process the application input
    pub fn processInput(self: *Self, delta: f64) void {
        // TODO(devon): Remove when shipping
        var camera = cam.currentCamera().?;

        if (Input.keyPressed(DrossKey.KeyEscape)) c.glfwSetWindowShouldClose(app_window, c.GL_TRUE);

        if (Input.keyReleased(DrossKey.KeyF1)) {
            if (debug_mode) {
                debug_mode = false;
                pause = false;
                self.setWindowTitle("Dross-Zig Application");
            } else {
                debug_mode = true;
                self.setWindowTitle("[DEBUG] Dross-Zig Application");
            }
        }

        if (Input.keyReleased(DrossKey.KeyP)) {
            if (debug_mode) {
                if (pause) {
                    pause = false;
                    self.setWindowTitle("[DEBUG] Dross-Zig Application");
                } else {
                    pause = true;
                    self.setWindowTitle("[DEBUG][PAUSED] Dross-Zig Application");
                }
            }
        }

        if (debug_mode) {
            var camera_pos = camera.position();
            const camera_zoom = camera.zoom();
            var delta_pos = Vector3.zero();
            const delta32: f32 = @floatCast(f32, delta);
            const camera_speed = camera.speed() * delta32;

            // Zoom in
            if (Input.keyPressed(DrossKey.KeyU)) {
                camera.setZoom(camera_zoom - delta32);
            }

            // Zoom out
            if (Input.keyPressed(DrossKey.KeyI)) {
                camera.setZoom(camera_zoom + delta32);
            }

            // Right
            if (Input.keyPressed(DrossKey.KeyL)) {
                var dir = Vector3.right().scale(-1.0); //Vector3.forward().scale(-1.0).cross(Vector3.up()).normalize();
                delta_pos = delta_pos.add(dir.scale(camera_speed));
            }

            // Left
            if (Input.keyPressed(DrossKey.KeyH)) {
                var dir = Vector3.right(); //.scale(1.0).cross(Vector3.up()).normalize();
                delta_pos = delta_pos.add(dir.scale(camera_speed));
            }

            // Up
            if (Input.keyPressed(DrossKey.KeyK)) {
                var dir = Vector3.up().scale(-1.0); //Vector3.forward().scale(-1.0).cross(Vector3.up()).normalize();
                delta_pos = delta_pos.add(dir.scale(camera_speed));
            }

            // Down
            if (Input.keyPressed(DrossKey.KeyJ)) {
                var dir = Vector3.up(); //.scale(1.0).cross(Vector3.up()).normalize();
                delta_pos = delta_pos.add(dir.scale(camera_speed));
            }

            // Reset Position and Zoom
            if (Input.keyPressed(DrossKey.KeyBackspace)) {
                delta_pos = Vector3.zero();
                camera_pos = Vector3.zero();
                camera.setZoom(1.0);
            }

            camera_pos = camera_pos.add(delta_pos);
            camera.setPosition(camera_pos);
        }
    }

    /// Resize the application
    pub fn resize(self: *Self, x: c_int, y: c_int, width: c_int, height: c_int) void {
        _ = self;
        // Call renderer's resize method
        Renderer.resizeViewport(x, y, width, height);
        setWindowSize(@intToFloat(f32, width), @intToFloat(f32, height));
    }

    /// Sets the application's window title
    pub fn setWindowTitle(self: *Self, title: [*c]const u8) void {
        _ = self;
        c.glfwSetWindowTitle(app_window, title);
    }

    /// Returns the application's window
    pub fn window() *c.GLFWwindow {
        return app_window;
    }

    /// Returns the size of the application's window as a Vector2
    pub fn windowSize() Vector2 {
        return window_size;
    }

    /// Sets the window size property
    pub fn setWindowSize(width: f32, height: f32) void {
        window_size = Vector2.new(width, height);
    }

    /// Sets the viewport size
    pub fn setViewport(width: f32, height: f32) void {
        viewport_size = Vector2.new(width, height);
    }

    /// Returns the viewport size
    pub fn viewportSize() Vector2 {
        return viewport_size;
    }
};
