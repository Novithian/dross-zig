// Third-Party
const c = @import("../c_global.zig").c_imp;
const std = @import("std");
// dross-rs
const gfx = @import("../renderer/renderer.zig");
const cam = @import("../renderer/cameras/camera_2d.zig");
const EventLoop = @import("event_loop.zig");
const Vector2 = @import("../core/vector2.zig").Vector2;
const Vector3 = @import("../core/vector3.zig").Vector3;
const input = @import("input.zig");
const Input = input.Input;
const DrossKey = input.DrossKey;
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

/// Stores the current size of the window
var window_size: Vector2 = undefined;

/// Stores the window to allow other systems
/// to communicate with it without needing a 
/// Application instance.
var window: *c.GLFWwindow = undefined;

// -----------------------------------------
//      - Application -
// -----------------------------------------

/// Application is the center point of the entire program.
/// Most of the communication from the end-user will come
/// through the application instance.
pub const Application = struct {
    allocator: ?*std.mem.Allocator = undefined,
    previous_frame_time: f64 = 0,

    /// Runs the applications main event loop. 
    pub fn run(self: *Application) void {
        while (c.glfwWindowShouldClose(window) == 0) {
            // Calculate timestep
            const current_time = c.glfwGetTime();
            var delta = current_time - self.previous_frame_time;
            self.previous_frame_time = current_time;

            // TODO(devon): Remove when shipping
            if (debug_mode and pause) delta = 0;

            // Process input
            self.processInput(delta);

            // Update
            EventLoop.updateInternal(delta);

            // Render
            gfx.Renderer.render();

            // Submit
            c.glfwSwapBuffers(window);
            c.glfwPollEvents();
        }
    }

    /// Allocates the necessary components to run the application
    /// Comments: The application will own any memory allocated.
    pub fn build(self: *Application, allocator: *std.mem.Allocator, title: [*c]const u8, width: c_int, height: c_int) anyerror!void {
        // Initialze GLFW, returns GL_FALSE if an error occured.
        if (c.glfwInit() == c.GL_FALSE) return ApplicationError.WindowInit;

        // GLFW Configuration
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 5);
        c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
        c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);

        // Window Creation
        window = c.glfwCreateWindow(width, height, title, null, null) orelse return ApplicationError.WindowCreation;

        // Set the global variables
        window_size = Vector2.new(
            @intToFloat(f32, width),
            @intToFloat(f32, height),
        );

        // Make our window the current context
        c.glfwMakeContextCurrent(window);

        // Build the Renderer
        try gfx.buildRenderer(allocator);

        // Remember to set the app's allocator to the passed allocator
        self.allocator = allocator;

        _ = c.glfwSetFramebufferSizeCallback(window, gfx.Renderer.resizeInternal);

        // Resize the application's viewport to match that of the window
        self.resize(0, 0, width, height);

        // Make sure there is at least a single Camera instance
        try cam.buildCamera2d(allocator);

        try Input.build(allocator);
    }

    /// Gracefully terminates the Application by cleaning up
    /// manually allocated memory as well as some other backend
    /// cleanup.
    /// Comments: Be sure to call before exiting program!    
    /// defer gpa.allocator.destroy(app);
    /// defer app.*.free()
    pub fn free(self: *Application) void {
        c.glfwDestroyWindow(window);
        c.glfwTerminate();

        // Manually allocated memory cleanup
        Input.free(self.allocator.?);
        cam.freeAllCamera2d(self.allocator.?);
        try gfx.freeRenderer(self.allocator.?);
    }

    /// Process the application input
    pub fn processInput(self: *Application, delta: f64) void {
        // TODO(devon): Remove when shipping
        var camera: *cam.Camera2d = cam.getCurrentCamera().?;
        if (Input.getKeyPressed(DrossKey.KeyEscape)) c.glfwSetWindowShouldClose(window, c.GL_TRUE);
        if (Input.getKeyReleased(DrossKey.KeyF1)) {
            if (debug_mode) {
                debug_mode = false;
                pause = false;
                self.setWindowTitle("Dross-Zig Application");
            } else {
                debug_mode = true;
                self.setWindowTitle("[DEBUG] Dross-Zig Application");
            }
        }
        if (Input.getKeyPressed(DrossKey.KeyP)) {
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
            var camera_pos = camera.getPosition();
            const camera_zoom = camera.getZoom();
            var delta_pos = Vector3.zero();
            const camera_speed = camera.getSpeed() * @floatCast(f32, delta);

            // Zoom in
            if (Input.getKeyPressed(DrossKey.KeyU)) {
                camera.setZoom(camera_zoom - camera_speed);
            }
            // Zoom out
            if (Input.getKeyPressed(DrossKey.KeyI)) {
                camera.setZoom(camera_zoom + camera_speed);
            }
            // Right
            if (Input.getKeyPressed(DrossKey.KeyL)) {
                var dir = Vector3.right().scale(-1.0); //Vector3.forward().scale(-1.0).cross(Vector3.up()).normalize();
                delta_pos = delta_pos.add(dir.scale(camera_speed));
            }
            // Left
            if (Input.getKeyPressed(DrossKey.KeyH)) {
                var dir = Vector3.right(); //.scale(1.0).cross(Vector3.up()).normalize();
                delta_pos = delta_pos.add(dir.scale(camera_speed));
            }
            // Up
            if (Input.getKeyPressed(DrossKey.KeyK)) {
                var dir = Vector3.up().scale(-1.0); //Vector3.forward().scale(-1.0).cross(Vector3.up()).normalize();
                delta_pos = delta_pos.add(dir.scale(camera_speed));
            }
            // Down
            if (Input.getKeyPressed(DrossKey.KeyJ)) {
                var dir = Vector3.up(); //.scale(1.0).cross(Vector3.up()).normalize();
                delta_pos = delta_pos.add(dir.scale(camera_speed));
            }
            // Reset Position and Zoom
            if (Input.getKeyPressed(DrossKey.KeyBackspace)) {
                delta_pos = Vector3.zero();
                camera_pos = Vector3.zero();
                camera.setZoom(1.0);
            }

            camera_pos = camera_pos.add(delta_pos);
            camera.setPosition(camera_pos);
        }
    }

    /// Resize the application
    pub fn resize(self: *Application, x: c_int, y: c_int, width: c_int, height: c_int) void {
        // Call renderer's resize method
        gfx.Renderer.resizeViewport(x, y, width, height);
    }

    /// Sets the application's window title
    pub fn setWindowTitle(self: *Application, title: [*c]const u8) void {
        c.glfwSetWindowTitle(window, title);
    }

    /// Returns the application's window
    pub fn getWindow() *c.GLFWwindow {
        return window;
    }
};

/// Allocated and builds the constituent components of an Application.
/// Comments: The caller will be the owner of the returned pointer.
pub fn buildApplication(allocator: *std.mem.Allocator, title: [*c]const u8, width: c_int, height: c_int) anyerror!*Application {
    var app: *Application = try allocator.create(Application);

    try app.build(allocator, title, width, height);

    return app;
}
