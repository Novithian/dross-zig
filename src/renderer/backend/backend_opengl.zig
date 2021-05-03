const c = @import("../../c_global.zig").c_imp;

// -----------------------------------------
//      - OpenGL Backend -
// -----------------------------------------
pub const OpenGlError = error{
    GladFailure,
};

/// Backend Implmentation for OpenGL
/// Returns: void
/// Comment: This is for INTERNAL use only.
// GO THROUGH THE RENDERER
pub const OpenGlBackend = struct {

    /// Handles the OpenGL specific functionality
    /// Returns: void
    /// Comment: INTERNAL use only.
    pub fn render(self: *OpenGlBackend, r: f32, g: f32, b: f32) void {
        c.glClearColor(r, g, b, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
    }
};

/// Resizes the viewport to the given size and position 
/// Returns: void
/// x: c_int - x position of the viewport
/// y: c_int - y position of the viewport
/// width: c_int - width of the viewport
/// height: c_int - height of the viewport
/// Comment: This is for INTERNAL use only.
pub fn resizeViewport(x: c_int, y: c_int, width: c_int, height: c_int) void {
    c.glViewport(x, y, width, height);
}

/// Calls the GLAD specific code required for setting up
/// Returns: anyerror!void
/// gl: *OpenGLBackend - The allocated OpenGL backend
/// Comment: This is for INTERNAL use only.
pub fn build(gl: *OpenGlBackend) anyerror!void {
    if (c.gladLoadGLLoader(@ptrCast(c.GLADloadproc, c.glfwGetProcAddress)) == 0) return OpenGlError.GladFailure;
}
