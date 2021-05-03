// Third-Party
const c = @import("../c_global.zig").c_imp;
const std = @import("std");
// dross-rs
const gfx = @import("../renderer/renderer.zig");

/// User defined update/tick function
/// Returns: void
pub extern fn update(delta: f64) void;

/// Error Set for Application-related Errors
pub const ApplicationError = error{
    OutOfMemory,
    RendererCreation,
    WindowCreation,
    WindowInit,
};

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

    /// Runs the applications main event loop. 
    /// Returns: void
    pub fn run(self: *Application) void {
        while (c.glfwWindowShouldClose(self.window) == 0) {
            // Process input

            // Update
            update(1.0);

            // Render
            self.renderer.?.render();

            // Submit
            c.glfwSwapBuffers(self.window);
            c.glfwPollEvents();
        }
    }

    /// Gracefully terminates the Application by cleaning up
    /// manually allocated memory as well as some other backend
    /// cleanup.
    /// Returns: void
    /// Comment: Be sure to call before exiting program!    
    /// defer gpa.allocator.destroy(app);
    /// defer app.*.free()
    pub fn free(self: *Application) void {
        c.glfwDestroyWindow(self.window);
        c.glfwTerminate();

        // Manually allocated memory cleanup
        if (self.renderer != null) self.renderer.?.free(self.allocator.?);
        self.allocator.?.destroy(self.renderer.?);
    }

    /// Resize the application
    /// Returns: void
    /// x: c_int - x position of the application
    /// y: c_int
    pub fn resize(self: *Application, x: c_int, y: c_int, width: c_int, height: c_int) void {
        // Call renderer's resize method
        self.renderer.?.resizeViewport(x, y, width, height);
    }

    /// TODO(devon): write desc title
    pub fn setWindowTitle(self: *Application, title: [*c]const u8) void {
        c.glfwSetWindowTitle(self.window, title);
    }
};

/// Allocated and builds the constituent components of an Application.
/// Returns: anyerror!*Application
/// allocator: *std.mem.Allocator - The main application allocator
/// title: [*c]const u8 - The title of the application's window
/// width: c_int - The initial width of the application's window
/// height: c_int - The initial height of the application's window
pub fn build(allocator: *std.mem.Allocator, title: [*c]const u8, width: c_int, height: c_int) anyerror!*Application {
    var app: *Application = try allocator.create(Application);

    // Initialze GLFW, returns GL_FALSE if an error occured.
    if (c.glfwInit() == c.GL_FALSE) return ApplicationError.WindowInit;

    // GLFW Configuration
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 5);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);

    // Window Creation
    app.window = c.glfwCreateWindow(width, height, title, null, null) orelse return ApplicationError.WindowCreation;

    // Make our window the current context
    c.glfwMakeContextCurrent(app.window);

    // Build the Renderer
    app.renderer = try gfx.build(allocator);

    // Remember to set the app's allocator to the passed allocator
    app.allocator = allocator;

    _ = c.glfwSetFramebufferSizeCallback(app.window, gfx.Renderer.resizeInternal);

    // Resize the application's viewport to match that of the window
    // app.resize(0, 0, width, height);

    return app;
}
