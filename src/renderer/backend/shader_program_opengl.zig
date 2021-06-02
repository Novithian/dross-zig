// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");

// dross-zig
const OpenGlError = @import("renderer_opengl.zig").OpenGlError;
const FileLoader = @import("../../utils/file_loader.zig");
const ShaderGl = @import("shader_opengl.zig").ShaderGl;
const Matrix4 = @import("../../core/matrix4.zig").Matrix4;
const Vector3 = @import("../../core/vector3.zig").Vector3;
const Vector2 = @import("../../core/vector2.zig").Vector2;
// -----------------------------------------

// -----------------------------------------
//      - ShaderProgramGl -
// -----------------------------------------

/// The central point for the multiple shaders. The shaders are linked to this.
pub const ShaderProgramGl = struct {
    /// OpenGL generated ID
    handle: c_uint,

    const Self = @This();

    /// Allocates and build a ShaderProgramGl instance 
    /// Comments: The caller will own the allocated memory
    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var self = try allocator.create(ShaderProgramGl);

        self.handle = c.glCreateProgram();

        return self;
    }

    /// Cleans up and de-allocates ShaderProgramGl instance 
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        c.glDeleteProgram(self.handle);

        allocator.destroy(self);
    }

    /// Attaches the requested shader to be used for rendering
    pub fn attach(self: *Self, shader: *ShaderGl) void {
        c.glAttachShader(self.handle, shader.id());
    }

    /// Links the shader program and checks for any errors
    pub fn link(self: *Self) !void {
        var no_errors: c_int = undefined;
        var linking_log: [512]u8 = undefined;

        c.glLinkProgram(self.handle);

        c.glGetProgramiv(self.handle, c.GL_LINK_STATUS, &no_errors);

        // If the linking failed, log the message
        if (no_errors == 0) {
            c.glGetProgramInfoLog(self.handle, 512, null, &linking_log);
            std.log.err("[Renderer][OpenGL]: Failed to link shader program: \n{s}", .{linking_log});
            return OpenGlError.ShaderLinkingFailure;
        }
    }

    /// Tells OpenGL to make this the active pipeline
    pub fn use(self: *Self) void {
        c.glUseProgram(self.handle);
    }

    /// Sets a uniform boolean of `name` to the requested `value`
    pub fn setBool(self: *Self, name: [*c]const u8, value: bool) void {
        const uniform_location = c.glGetUniformLocation(self.handle, name);
        const int_value: c_int = @intCast(c_int, @boolToInt(value));
        c.glUniform1i(uniform_location, int_value);
    }

    /// Sets a uniform integer of `name` to the requested `value`
    pub fn setInt(self: *Self, name: [*c]const u8, value: i32) void {
        const uniform_location = c.glGetUniformLocation(self.handle, name);
        const int_value: c_int = @intCast(c_int, value);
        c.glUniform1i(uniform_location, int_value);
    }

    /// Sets a uniform integer of `name` to the requested `value`
    pub fn setIntArray(self: *Self, name: [*c]const u8, values: []c_int, count: u32) void {
        const uniform_location = c.glGetUniformLocation(self.handle, name);
        //const int_value: c_uint = @intCast(c_uint, values);
        const count_c: c_int = @intCast(c_int, count);
        c.glUniform1iv(uniform_location, count_c, @ptrCast(*const c_int, &values[0]));
    }

    /// Sets a uniform float of `name` to the requested `value`
    pub fn setFloat(self: *Self, name: [*c]const u8, value: f32) void {
        const uniform_location = c.glGetUniformLocation(self.handle, name);
        c.glUniform1f(uniform_location, value);
    }

    /// Sets a uniform vec3 of `name` to the corresponding values of the group of 3 floats
    pub fn setFloat3(self: *Self, name: [*c]const u8, x: f32, y: f32, z: f32) void {
        const uniform_location = c.glGetUniformLocation(self.handle, name);
        c.glUniform3f(uniform_location, x, y, z);
    }

    /// Sets a uniform vec4 of `name` to the corresponding values of the group of 3 floats
    pub fn setFloat4(self: *Self, name: [*c]const u8, x: f32, y: f32, z: f32, w: f32) void {
        const uniform_location = c.glGetUniformLocation(self.handle, name);
        c.glUniform4f(uniform_location, x, y, z, w);
    }

    /// Sets a uniform vec3 of `name` to the corresponding values of the group of 3 floats
    pub fn setVector3(self: *Self, name: [*c]const u8, vector: Vector3) void {
        const uniform_location: c_int = c.glGetUniformLocation(self.handle, name);
        const data = vector.data.to_array();
        const gl_error = c.glGetError();
        if (gl_error != c.GL_NO_ERROR) {
            std.debug.print("{}\n", .{gl_error});
        }
        c.glUniform3fv(
            uniform_location, // Location
            1, // Count
            @ptrCast(*const f32, &data[0]), // Data
        );
    }

    /// Sets a uniform mat4 of `name` to the requested `value`
    pub fn setMatrix4(self: *Self, name: [*c]const u8, matrix: Matrix4) void {
        const uniform_location = c.glGetUniformLocation(self.handle, name);
        c.glUniformMatrix4fv(uniform_location, // Location
            1, // Count
            c.GL_FALSE, // Transpose
            @ptrCast(*const f32, &matrix.data.data) // Data pointer
        );
    }
};
