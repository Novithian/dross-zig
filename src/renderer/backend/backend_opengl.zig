// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");

// dross-zig
const Color = @import("../../core/core.zig").Color;
const texture = @import("../texture.zig");

// Testing vertices and indices
// zig fmt: off
const square_vertices: [32]f32 = [32]f32{
    // Positions        | Colors        | Texture coords
    0.5, 0.5, 0.0,      1.0, 0.0, 0.0,  1.0, 1.0, // Top Right
    0.5, -0.5, 0.0,     0.0, 1.0, 0.0,  1.0, 0.0,// Bottom Right
    -0.5, -0.5, 0.0,    0.0, 0.0, 1.0,  0.0, 0.0,// Bottom Left
    -0.5, 0.5, 0.0,     1.0, 1.0, 1.0,  0.0, 1.0,// Top Left
};

const square_indices: [6]c_uint = [6]c_uint{
    0, 1, 3,
    1, 2, 3,
};

const square_tex_coords: [8]f32 = [8]f32{
    0.0, 0.0, // Bottom left
    1.0, 0.0, // Bottom right
    1.0, 1.0, // Top right
    0.0, 1.0, // Top left
};

// -----------------------------------------
//      - OpenGL Reference Material -
// -----------------------------------------
// OpenGL Types: https://www.khronos.org/opengl/wiki/OpenGL_Type
// Beginners:    https://learnopengl.com/Introduction

// -----------------------------------------
//      - GLSL Default Shaders -
// -----------------------------------------
const default_shader_vs: [:0]const u8 = "default_shader.vs";
const default_shader_fs: [:0]const u8 = "default_shader.fs";

// -----------------------------------------
//      - OpenGL Errors -
// -----------------------------------------
/// Error set for OpenGL related errors 
pub const OpenGlError = error{
    /// Glad failed to initialize
    GladFailure,
    /// Failure during shader compilation
    ShaderCompilationFailure,
    /// Failure during shader program linking
    ShaderLinkingFailure,
};

// -----------------------------------------
//      - OpenGL Backend -
// -----------------------------------------

/// Backend Implmentation for OpenGL
/// Returns: void
/// Comment: This is for INTERNAL use only. 
pub const OpenGlBackend = struct {
    shader_program: ?*GlShaderProgram,
    vertex_array: ?*GlVertexArray,
    vertex_buffer: ?*GlVertexBuffer,
    index_buffer: ?*GlIndexBuffer,

    debug_texture: ?*texture.Texture,

    /// Builds the necessary components for the OpenGL renderer
    /// allocator: *std.mem.Allocator - The allocator used to manually allocate any necessary resources
    /// Returns: anyerror!void
    /// Comment: INTERNAL use only. The OpenGlBackend will be the owner of the allocated memory.
    pub fn build(self: *OpenGlBackend, allocator: *std.mem.Allocator) anyerror!void {

        c.glPixelStorei(c.GL_UNPACK_ALIGNMENT, 1);

        // Allocate and compile the vertex shader
        var vertex_shader: *GlShader = try buildGlShader(allocator, GlShaderType.Vertex);
        try vertex_shader.source(default_shader_vs);
        try vertex_shader.compile();

        // Allocate and compile the fragment shader
        var fragment_shader: *GlShader = try buildGlShader(allocator, GlShaderType.Fragment);
        try fragment_shader.source(default_shader_fs);
        try fragment_shader.compile();

        // Allocate memory for the shader program
        self.shader_program = try buildGlShaderProgram(allocator);

        // Attach the shaders to the shader program
        self.shader_program.?.attach(vertex_shader);
        self.shader_program.?.attach(fragment_shader);

        // Link the shader program
        try self.shader_program.?.link();

        // Allow the shader to call the OpenGL-related cleanup functions
        vertex_shader.free();
        fragment_shader.free();

        // Free the memory as they are no longer needed
        defer allocator.destroy(vertex_shader);
        defer allocator.destroy(fragment_shader);

        // Create VAO, VBO, and IB
        self.vertex_array = try buildGlVertexArray(allocator);
        self.vertex_buffer = try buildGlVertexBuffer(allocator);
        self.index_buffer = try buildGlIndexBuffer(allocator);

        // Bind VAO
        // NOTE(devon): Order matters! Bind VAO first, and unbind last!
        self.vertex_array.?.bind();

        // Bind VBO
        self.vertex_buffer.?.bind();
        var vertices_slice = square_vertices[0..];
        self.vertex_buffer.?.data(vertices_slice, GlBufferUsage.StaticDraw);

        // Bind IB
        self.index_buffer.?.bind();
        var indicies_slice = square_indices[0..];
        self.index_buffer.?.data(indicies_slice, GlBufferUsage.StaticDraw);

        const size_of_vatb = 8;
        const stride = @intCast(c_longlong, @sizeOf(f32) * size_of_vatb);
        const offset_position: u32 = 0;
        const offset_color: u32 = 3 * @sizeOf(f32);
        const offset_tex: u32 =  6 * @sizeOf(f32); // position offset(0) + color offset + the length of the color bytes
        const index_zero: c_int = 0;
        const index_one: c_int = 1;
        const index_two: c_int = 2;
        const size: c_uint = 3;
        const tex_coord_size: c_uint = 2;

        // Tells OpenGL how to interpret the vertex data(per vertex attribute)
        // Uses the data to the currently bound VBO

        // glVertexAttribPointer(GLuint index, Glint size, GLenum type,
        //      GLboolean normalized, GLsizei stride, const GLvoid *pointer)

        // Position Attribute
        c.glVertexAttribPointer(
            index_zero, // Which vertex attribute we want to configure
            size, // Size of vertex attribute (vec3 in this case)
            c.GL_FLOAT, // Type of data
            c.GL_FALSE, // Should the data be normalized?
            stride, // Stride
            @intToPtr(?*c_void, offset_position), // Offset
        );

        // Vertex Attributes are disabled by default, we need to enable them.
        // glEnableVertexAttribArray(GLuint index)
        c.glEnableVertexAttribArray(index_zero);

        // Color Attribute
        c.glVertexAttribPointer(
            index_one, // Which vertex attribute we want to configure
            size, // Size of vertex attribute (vec3 in this case)
            c.GL_FLOAT, // Type of data
            c.GL_FALSE, // Should the data be normalized?
            stride, // Stride
            @intToPtr(?*c_void, offset_color), // Offset
        );

        // Enable Color Attributes
        c.glEnableVertexAttribArray(index_one);
        
        // Texture Coordinates Attribute
        c.glVertexAttribPointer(
            index_two, // Which vertex attribute we want to configure
            tex_coord_size, // Size of vertex attribute (vec2 in this case)
            c.GL_FLOAT, // Type of data
            c.GL_FALSE, // Should the data be normalized?
            stride, // Stride
            @intToPtr(?*c_void, offset_tex), // Offset
        );

        // Enable Color Attributes
        c.glEnableVertexAttribArray(index_two);

        // Unbind the VBO
        c.glBindBuffer(c.GL_ARRAY_BUFFER, index_zero);

        // NOTE(devon): Do NOT unbind the EBO while a VAO is active as the bound
        // bound element buffer object IS stored in the VAO; keep the EBO bound.
        // Unbind the EBO

        // Unbind the VAO
        c.glBindVertexArray(index_zero);

        // c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);

        // TODO(devon): remove 
        // For debug purposes only
        self.debug_texture = try texture.buildTexture(allocator);

    }

    /// Frees up any resources that was previously allocated
    /// allocator: *std.mem.Allocator - Allocator used to free the previously allocated resources
    /// Returns: void
    pub fn free(self: *OpenGlBackend, allocator: *std.mem.Allocator) void {
        // Allow for OpenGL object to de-allocate any memory it needed
        self.debug_texture.?.free(allocator);
        self.vertex_array.?.free();
        self.vertex_buffer.?.free();
        self.index_buffer.?.free();
        self.shader_program.?.free();

        // Free memory
        allocator.destroy(self.debug_texture.?);
        allocator.destroy(self.vertex_array.?);
        allocator.destroy(self.vertex_buffer.?);
        allocator.destroy(self.index_buffer.?);
        allocator.destroy(self.shader_program.?);
    }

    /// Handles the OpenGL specific functionality
    /// Returns: void
    /// Comment: INTERNAL use only.
    pub fn render(self: *OpenGlBackend, clear_color: Color) void {
        // Clear the background with the specified color
        c.glClearColor(clear_color.r, clear_color.g, clear_color.b, clear_color.a);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        // glUseProgramm(GLuint program)
        self.shader_program.?.use();

        // Bind Texture
        // c.glActiveTexture(c.GL_TEXTURE0);
        c.glBindTexture(c.GL_TEXTURE_2D, self.debug_texture.?.getGlId());

        self.vertex_array.?.bind();

        const number_of_vertices: i32 = 6;
        const offset = @intToPtr(?*c_void, 0);

        // glDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid* indices)
        c.glDrawElements(
            c.GL_TRIANGLES, // Primitive mode
            6, // Number of vertices/elements to draw
            c.GL_UNSIGNED_INT, // Type of values in indices
            offset, // Offset in a buffer or a pointer to the location where the indices are stored
        );
    } // End of render
};

/// Resizes the viewport to the given size and position 
/// Returns: void
/// x: c_int - x position of the viewport
/// y: c_int - y position of the viewport
/// width: c_int - width of the viewport
/// height: c_int - height of the viewport
/// Comment: This is for INTERNAL use only.
pub fn resizeViewport(x: c_int, y: c_int, width: c_int, height: c_int) void {
    // glViewport(GLint x, GLint y, GLsizei width, GLsizei height)
    c.glViewport(x, y, width, height);
}

/// Calls the GLAD specific code required for setting up
/// Returns: anyerror!void
/// allocator: *std.mem.Allocator - The allocator that will allocate the backend
/// Comment: Owned by the caller. This is for INTERNAL use only.
pub fn build(allocator: *std.mem.Allocator) anyerror!*OpenGlBackend {
    if (c.gladLoadGLLoader(@ptrCast(c.GLADloadproc, c.glfwGetProcAddress)) == 0) return OpenGlError.GladFailure;

    var backend = try allocator.create(OpenGlBackend);

    try backend.build(allocator);

    return backend;
}

// -----------------------------------------
//      - Buffer related -
// -----------------------------------------

/// Describes how the data is used over its lifetime.
const GlBufferUsage = enum(c_uint) {
    /// The data is set only once, and used by the GPU at 
    /// most a few times.
    StreamDraw = c.GL_STREAM_DRAW,
    /// The data is set only once, and used many times.
    StaticDraw = c.GL_STATIC_DRAW,
    /// The data is changes frequently, and used many times.
    DynamicDraw = c.GL_DYNAMIC_DRAW,
};

// -----------------------------------------
//      - Vertex Buffer Object -
// -----------------------------------------

/// Container for storing a large number of vertices in the GPU's memory.
const GlVertexBuffer = struct {
    /// OpenGL generated ID
    handle: c_uint,

    /// Builds the Vertex Buffer
    /// Returns: void
    pub fn build(self: *GlVertexBuffer) void {
        // glGenBuffers(GLsizei size, GLuint* buffers)
        c.glGenBuffers(1, &self.handle);
    }

    /// Frees the Vertex Buffer
    /// Returns: void
    pub fn free(self: *GlVertexBuffer) void {
        //glDeleteBuffer(GLsizei count, GLuint buffer))
        c.glDeleteBuffers(1, &self.handle);
    }

    /// Binds the Vertex Buffer to the current buffer target.
    /// Returns: void
    pub fn bind(self: *GlVertexBuffer) void {
        // glBindBuffer(GLenum target, GLuint buffer)
        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.handle);
    }

    /// Allocates memory and stores data within the the currently bound buffer object.
    /// Returns: void
    /// vertices: []const f32 - The vertices data to be written to the buffer object 
    /// usage: GlBufferUsage - Describes how the vertices will be used over its lifetime.
    pub fn data(self: GlVertexBuffer, vertices: []const f32, usage: GlBufferUsage) void {
        const vertices_ptr = @ptrCast(*const c_void, vertices.ptr);
        const vertices_size = @intCast(c_longlong, @sizeOf(f32) * vertices.len);

        // glBufferData(GLenum mode, Glsizeiptr size, const GLvoid* data, GLenum usage)
        c.glBufferData(c.GL_ARRAY_BUFFER, vertices_size, vertices_ptr, @enumToInt(usage));
    }
};

/// Allocates a vertex buffer and sets it up
/// Return: anyerror!GlVertexBuffer
/// allocator: *std.mem.Allocator - Allocator used to create the vertex buffer
/// Comments: The caller will own the returned pointer.
fn buildGlVertexBuffer(allocator: *std.mem.Allocator) anyerror!*GlVertexBuffer {
    var vbo = try allocator.create(GlVertexBuffer);

    vbo.build();

    return vbo;
}

// -----------------------------------------
//      - Index Buffer -
// -----------------------------------------

/// Stores indices that will be used to decide what vertices to draw.
const GlIndexBuffer = struct {
    /// OpenGL generated ID
    handle: c_uint,

    /// Build the Index Buffer
    /// Returns: void
    pub fn build(self: *GlIndexBuffer) void {
        // glGenBuffers(GLsizei size, GLuint* buffers)
        c.glGenBuffers(1, &self.handle);
    }

    /// Frees the Index Buffer
    /// Returns: void
    pub fn free(self: *GlIndexBuffer) void {
        //glDeleteBuffer(GLsizei count, GLuint buffer))
        c.glDeleteBuffers(1, &self.handle);
    }

    /// Binds the Index Buffer
    /// Returns: void
    pub fn bind(self: *GlIndexBuffer) void {
        // glBindBuffer(GLenum target, GLuint buffer)
        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, self.handle);
    }

    /// Allocates memory and stores data within the the currently bound buffer object.
    /// Returns: void
    /// indices: []const c_uint - The indices data to be written to the buffer object 
    /// usage: GlBufferUsage - Describes how the indices will be used over its lifetime.
    pub fn data(self: GlIndexBuffer, indices: []const c_uint, usage: GlBufferUsage) void {
        const indices_ptr = @ptrCast(*const c_void, indices.ptr);
        const indices_size = @intCast(c_longlong, @sizeOf(c_uint) * indices.len);

        // glBufferData(GLenum mode, Glsizeiptr size, const GLvoid* data, GLenum usage)
        c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, indices_size, indices_ptr, @enumToInt(usage));
    }
};

/// Allocates an Index Buffer and sets it up
/// Return: anyerror!GlIndexBuffer
/// allocator: *std.mem.Allocator - Allocator used to create the index buffer
/// Comments: The caller will own the returned pointer.
fn buildGlIndexBuffer(allocator: *std.mem.Allocator) anyerror!*GlIndexBuffer {
    var ib = try allocator.create(GlIndexBuffer);

    ib.build();

    return ib;
}

// -----------------------------------------
//      - Vertex Array Object -
// -----------------------------------------

/// Stores the Vertex Attributes
const GlVertexArray = struct {
    /// OpenGL generated ID
    handle: c_uint,

    /// Build and generates the OpenGL handle for the Vertex Array
    /// Returns: void
    pub fn build(self: *GlVertexArray) void {
        // glGenVertexArrays(GLsizei size, GLuint* array)
        c.glGenVertexArrays(1, &self.handle);
    }

    /// Frees the OpenGL generated handle
    /// Returns: void
    pub fn free(self: *GlVertexArray) void {
        //glDeleteBuffer(GLsizei count, GLuint array))
        c.glDeleteVertexArrays(1, &self.handle);
    }

    /// Binds the Vertex Array
    /// Returns: void
    pub fn bind(self: *GlVertexArray) void {
        // glBindVertexArray(GLuint array)
        c.glBindVertexArray(self.handle);
    }
};

/// Allocates an Vertex Array and sets it up
/// Return: anyerror!GlVertexArray
/// allocator: *std.mem.Allocator - Allocator used to create the GlVertexArray
/// Comments: The caller will own the returned pointer.
fn buildGlVertexArray(allocator: *std.mem.Allocator) anyerror!*GlVertexArray {
    var vao = try allocator.create(GlVertexArray);

    vao.build();

    return vao;
}

// -----------------------------------------
//      - GlShaderType -
// -----------------------------------------

/// Describes what type of shader 
pub const GlShaderType = enum(c_uint) {
    Vertex = c.GL_VERTEX_SHADER,
    Fragment = c.GL_FRAGMENT_SHADER,
    Geometry = c.GL_GEOMETRY_SHADER,
};

// -----------------------------------------
//      - GlShaders -
// -----------------------------------------

/// Container that processes and compiles a sources GLSL file
const GlShader = struct {
    /// OpenGL generated ID
    handle: c_uint,
    shader_type: GlShaderType,

    /// Builds the shader of the requested shader type
    /// Returns: void
    /// shader_type: GlShaderType - The type of shader to be built
    pub fn build(self: *GlShader, shader_type: GlShaderType) void {
        // glCreateShader(GLenum shaderType)
        self.handle = c.glCreateShader(@enumToInt(shader_type));
        self.shader_type = shader_type;
    }

    /// Frees the stored shader handle
    /// Returns: void
    pub fn free(self: *GlShader) void {
        //glDeleteShader(GLuint shader)
        c.glDeleteShader(self.handle);
    }

    /// Sources a given GLSL shader file
    /// Returns: anyerror!void
    /// filename: [:0]const u8 - The filename of the source GLSL file
    pub fn source(self: *GlShader, filename: [:0]const u8) anyerror!void {
        // Open the shader directory
        var dir = try std.fs.cwd().openDir(
            "src/renderer/shaders",
            .{},
        );

        // Get the source file
        const file = try dir.openFile(
            filename,
            .{},
        );

        defer (&dir).close();
        defer file.close();

        // Create a buffer to store the file read in
        var file_buffer: [4096]u8 = undefined;

        try file.seekTo(0);

        const source_bytes = try file.readAll(&file_buffer);
        const source_slice = file_buffer[0..source_bytes];
        const source_size = source_slice.len;

        //glShaderSource(GLuint shader, GLsizei count, const GLchar** string, const GLint *length)
        c.glShaderSource(self.handle, 1, &source_slice.ptr, @ptrCast(*const c_int, &source_size));
    }

    /// Compiles the previously sources GLSL shader file, and checks for any compilation errors.
    /// Returns: anyerror!void
    pub fn compile(self: *GlShader) anyerror!void {
        var no_errors: c_int = undefined;
        var compilation_log: [512]u8 = undefined;

        //glCompileShader(GLuint shader)
        c.glCompileShader(self.handle);

        //glGetShaderiv(GLuint shader, GLenum pname, GLint *params)
        c.glGetShaderiv(self.handle, c.GL_COMPILE_STATUS, &no_errors);

        // If the compilation failed, log the message
        if (no_errors == 0) {
            //glGetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog)
            c.glGetShaderInfoLog(self.handle, 512, null, &compilation_log);
            std.log.err("[Renderer][OpenGL]: Failed to compile {s} shader: \n{s}", .{ self.shader_type, compilation_log });
            return OpenGlError.ShaderCompilationFailure;
        }
    }
};

/// Allocates an GlShader and sets it up
/// Return: anyerror!GlShader
/// allocator: *std.mem.Allocator - Allocator used to create the GlShader
/// shader_type: GlShaderType - The type of shader to be built
/// Comments: The caller will own the returned pointer.
fn buildGlShader(allocator: *std.mem.Allocator, shader_type: GlShaderType) anyerror!*GlShader {
    var shader = try allocator.create(GlShader);

    shader.build(shader_type);

    return shader;
}

// -----------------------------------------
//      - GlShaderProgram -
// -----------------------------------------

/// The central point for the multiple shaders. The shaders are linked to this.
const GlShaderProgram = struct {
    /// OpenGL generated ID
    handle: c_uint,

    const Self = @This();

    /// Builds the shader program
    /// Returns: void
    pub fn build(self: *Self) void {
        // glCreateProgram()
        self.handle = c.glCreateProgram();
    }

    /// Frees the OpenGL reference
    pub fn free(self: *Self) void {
        //glDeleteProgram(GLuint program)
        c.glDeleteProgram(self.handle);
    }

    /// Attaches the requested shader to be used for rendering
    /// Returns: void
    /// shader: *GlShader - A pointer to the requested shader
    pub fn attach(self: *Self, shader: *GlShader) void {
        //glAttachShaer(GLuint program, GLuint shader)
        c.glAttachShader(self.handle, shader.*.handle);
    }

    /// Links the shader program and checks for any errors
    /// Returns: anyerror!void
    pub fn link(self: *Self) anyerror!void {
        var no_errors: c_int = undefined;
        var linking_log: [512]u8 = undefined;

        //glLinkProgram(GLuint program)
        c.glLinkProgram(self.handle);

        //glGetShaderiv(GLuint shader, GLenum pname, GLint *params)
        c.glGetProgramiv(self.handle, c.GL_LINK_STATUS, &no_errors);

        // If the linking failed, log the message
        if (no_errors == 0) {
            //glGetProgramInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog)
            c.glGetProgramInfoLog(self.handle, 512, null, &linking_log);
            std.log.err("[Renderer][OpenGL]: Failed to link shader program: \n{s}", .{linking_log});
            return OpenGlError.ShaderLinkingFailure;
        }
    }

    /// Tells OpenGL to make this the active pipeline
    /// Returns: void
    pub fn use(self: *Self) void {
        // glUseProgram(GLuint)
        c.glUseProgram(self.handle);
    }

    /// Sets a uniform boolean of `name` to the requested `value`
    /// Returns: void
    /// name: [:0]const u8 - The name of the uniform
    /// value: bool - The value to set the uniform to
    pub fn setBool(self: *Self, name: [:0]const u8, value: bool) void {
        const uniform_location = c.glUniformLocation(self.handle, &name.ptr);
        const int_value: c_int = @as(c_int, value);
        // glUniform1i(GLint location, GLint)
        c.glUniform1i(uniform_location, int_value);
    }

    /// Sets a uniform integer of `name` to the requested `value`
    /// Returns: void
    /// name: [:0]const u8 - The name of the uniform
    /// value: i32 - The value to set the uniform to
    pub fn setInt(self: *Self, name: [:0]const u8, value: i32) void {
        const uniform_location = c.glUniformLocation(self.handle, &name.ptr);
        const int_value: c_int = @as(c_int, value);
        // glUniform1i(GLint location, GLint)
        c.glUniform1i(uniform_location, int_value);
    }

    /// Sets a uniform float of `name` to the requested `value`
    /// Returns: void
    /// name: [:0]const u8 - The name of the uniform
    /// value: f32 - The value to set the uniform to
    pub fn setFloat(self: *Self, name: [:0]const u8, value: f32) void {
        const uniform_location = c.glUniformLocation(self.handle, &name.ptr);
        // glUniform1f(GLint location, GLfloat)
        c.glUniform1f(uniform_location, value);
    }
};

/// Allocates an GlShaderProgram and sets it up
/// Return: anyerror!GlShaderProgram
/// allocator: *std.mem.Allocator - Allocator used to create the GlShaderProgram
/// Comments: The caller will own the returned pointer.
fn buildGlShaderProgram(allocator: *std.mem.Allocator) anyerror!*GlShaderProgram {
    var sp = try allocator.create(GlShaderProgram);

    sp.build();

    return sp;
}

test "Read Shader Test" {
    const file = try std.fs.cwd().openFile(
        "src/renderer/shaders/default_shader.vs",
        .{},
    );

    defer file.close();

    var buffer: [4096]u8 = undefined;
    try file.seekTo(0);
    const bytes_read = try file.readAll(&buffer);
    const slice = buffer[0..bytes_read];
    std.debug.print("{s}\n", .{slice});
}
