// Third-Party
const c = @import("../c_global.zig").c_imp;
const std = @import("std");
const Vec2 = @import("zalgebra").vec2;
// dross-rs
const gfx = @import("../renderer/renderer.zig");
const cam = @import("../renderer/cameras/camera_2d.zig");

/// User defined update/tick function
pub extern fn update(delta: f64) void;

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

pub var window_size: Vec2 = undefined;

// -----------------------------------------
//      - Application -
// -----------------------------------------

/// Application is the center point of the entire program.
/// Most of the communication from the end-user will come
/// through the application instance.
pub const Application = struct {
    renderer: ?*gfx.Renderer = undefined,
    window: *c.GLFWwindow = undefined,
    allocator: ?*std.mem.Allocator = undefined,
    previous_frame_time: f64 = 0,

    /// Runs the applications main event loop. 
    pub fn run(self: *Application) void {
        while (c.glfwWindowShouldClose(self.window) == 0) {
            // Calculate timestep
            const current_time = c.glfwGetTime();
            var delta = current_time - self.previous_frame_time;
            self.previous_frame_time = current_time;

            // TODO(devon): Remove when shipping
            if (debug_mode and pause) delta = 0;

            // Process input
            self.processInput();

            // Update
            update(delta);

            // Render
            self.renderer.?.render(delta);

            // Submit
            c.glfwSwapBuffers(self.window);
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
        self.window = c.glfwCreateWindow(width, height, title, null, null) orelse return ApplicationError.WindowCreation;

        // Set the global variables
        window_size = Vec2.new(
            @intToFloat(f32, width),
            @intToFloat(f32, height),
        );

        // Make our window the current context
        c.glfwMakeContextCurrent(self.window);

        // Build the Renderer
        self.renderer = try gfx.buildRenderer(allocator);

        // Remember to set the app's allocator to the passed allocator
        self.allocator = allocator;

        _ = c.glfwSetFramebufferSizeCallback(self.window, gfx.Renderer.resizeInternal);

        // Resize the application's viewport to match that of the window
        // app.resize(0, 0, width, height);

        // Make sure there is at least a single Camera instance
        try cam.buildCamera2d(allocator);
    }

    /// Gracefully terminates the Application by cleaning up
    /// manually allocated memory as well as some other backend
    /// cleanup.
    /// Comments: Be sure to call before exiting program!    
    /// defer gpa.allocator.destroy(app);
    /// defer app.*.free()
    pub fn free(self: *Application) void {
        c.glfwDestroyWindow(self.window);
        c.glfwTerminate();

        // Manually allocated memory cleanup
        cam.freeAllCamera2d(self.allocator.?);
        if (self.renderer != null) self.renderer.?.free(self.allocator.?);
        self.allocator.?.destroy(self.renderer.?);
    }

    /// Process the application input
    pub fn processInput(self: *Application) void {
        // TODO(devon): Remove when shipping
        if (c.glfwGetKey(self.window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) c.glfwSetWindowShouldClose(self.window, c.GL_TRUE);
        if (c.glfwGetKey(self.window, c.GLFW_KEY_F1) == c.GLFW_PRESS) {
            if (debug_mode) {
                debug_mode = false;
                pause = false;
                self.setWindowTitle("Dross-Zig Application");
            } else {
                debug_mode = true;
                self.setWindowTitle("[DEBUG] Dross-Zig Application");
            }
        }
        if (c.glfwGetKey(self.window, c.GLFW_KEY_P) == c.GLFW_PRESS) {
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
    }

    /// Resize the application
    pub fn resize(self: *Application, x: c_int, y: c_int, width: c_int, height: c_int) void {
        // Call renderer's resize method
        self.renderer.?.resizeViewport(x, y, width, height);
    }

    /// Sets the application's window title
    pub fn setWindowTitle(self: *Application, title: [*c]const u8) void {
        c.glfwSetWindowTitle(self.window, title);
    }
};

/// Allocated and builds the constituent components of an Application.
/// Comments: The caller will be the owner of the returned pointer.
pub fn buildApplication(allocator: *std.mem.Allocator, title: [*c]const u8, width: c_int, height: c_int) anyerror!*Application {
    var app: *Application = try allocator.create(Application);

    try app.build(allocator, title, width, height);

    return app;
}
