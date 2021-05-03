const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
const Color = @import("../../core/core.zig").Color;

// Test triangle
const test_triangle_vertices: [9]f32 = [9]f32{
    -0.5, -0.5, 0.0,
    0.5,  -0.5, 0.0,
    0.0,  0.5,  0.0,
};

// -----------------------------------------
//      - OpenGL Reference Material -
// -----------------------------------------
// OpenGL Types: https://www.khronos.org/opengl/wiki/OpenGL_Type
// Beginners:    https://learnopengl.com/Introduction

// -----------------------------------------
//      - GLSL Default Shaders -
// -----------------------------------------
const default_vertex_shader: [:0]const u8 = 
    \\#version 450 core
    \\layout (location = 0) in vec3 in_pos;
    \\void main(){
    \\  gl_Position = vec4(in_pos.x, in_pos.y, in_pos.z, 1.0);
    \\}
;

const default_fragment_shader: [:0]const u8 = 
    \\#version 450 core
    \\out vec4 out_color;
    \\void main(){
    \\  out_color = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    \\}
;
// -----------------------------------------
//      - OpenGL Errors -
// -----------------------------------------
// TODO(devon): desc gl error
pub const OpenGlError = error{
    GladFailure,
    ShaderCompilationFailure,
    ShaderLinkingFailure,
};

// -----------------------------------------
//      - OpenGL Backend -
// -----------------------------------------

/// Backend Implmentation for OpenGL
/// Returns: void
/// Comment: This is for INTERNAL use only.
// GO THROUGH THE RENDERER
pub const OpenGlBackend = struct {

    shader_program: ?*GlShaderProgram,
    vertex_array: ?*GlVertexArray,
    vertex_buffer: ?*GlVertexBuffer,

    /// TODO(devon): write desc gl build
    pub fn build(self: *OpenGlBackend, allocator: *std.mem.Allocator) anyerror!void {
        // Allocate and compile the vertex shader
        var vertex_shader: *GlShader = try buildGlShader(allocator, GlShaderType.Vertex);
        vertex_shader.source(default_vertex_shader);
        try vertex_shader.compile();

        // Allocate and compile the fragment shader
        var fragment_shader: *GlShader = try buildGlShader(allocator, GlShaderType.Fragment);
        fragment_shader.source(default_fragment_shader);
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

        // Create VAO, VBO, and EBO
        self.vertex_array = try buildGlVertexArray(allocator);
        self.vertex_buffer = try buildGlVertexBuffer(allocator);
        // EBO

        // Bind VAO 
        // NOTE(devon): Order matters! Bind VAO first, and unbind last!
        self.vertex_array.?.bind();

        // Bind VBO
        self.vertex_buffer.?.bind();
        var vertices_slice = test_triangle_vertices[0..];
        self.vertex_buffer.?.data(vertices_slice, GlBufferUsage.StaticDraw);

        // Bind EBO

        const size_of_vatb =  3;
        const stride =  @intCast(c_longlong, @sizeOf(f32) * size_of_vatb);
        const offset: u32 = 0;
        const index_zero: c_int = 0;

        // Tells OpenGL how to interpret the vertex data(per vertex attribute)
        // Uses the data to the currently bound VBO

        // glVertexAttribPointer(GLuint index, Glint size, GLenum type,
        //      GLboolean normalized, GLsizei stride, const GLvoid *pointer)
        c.glVertexAttribPointer(
            index_zero, // Which vertex attribute we want to configure
            @intCast(c_uint, 3),          // Size of vertex attribute (vec3 in this case)
            c.GL_FLOAT, // Type of data 
            c.GL_FALSE, // Should the data be normalized?
            stride,     // Stride
            @intToPtr(?*c_void, offset), // Offset
        );

        // Vertex Attributes are disabled by default, we need to enable them.
        // glEnableVertexAttribArray(GLuint index)
        c.glEnableVertexAttribArray(index_zero);

        // Unbind the VBO
        c.glBindBuffer(c.GL_ARRAY_BUFFER, index_zero);

        // NOTE(devon): Do NOT unbind the EBO while a VAO is active as the bound
        // bound element buffer object IS stored in the VAO; keep the EBO bound.
        // Unbind the EBO

        // Unbind the VAO
        c.glBindVertexArray(index_zero);

    }

    /// TODO(devon): write desc gl free
    pub fn free(self: *OpenGlBackend, allocator: *std.mem.Allocator) void {
        // Allow for OpenGL object to de-allocate any memory it needed
        self.vertex_array.?.free();
        self.vertex_buffer.?.free();
        // EBO
        self.shader_program.?.free();

        // Free memory
        allocator.destroy(self.vertex_array.?);
        allocator.destroy(self.vertex_buffer.?);
        // EBO
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
        c.glUseProgram(self.shader_program.?.handle);
        
        self.vertex_array.?.bind();

        const starting_index: c_uint = 0;
        const number_of_vertices: c_uint = 3;
        // glDrawArray(GLenum mode, GLint first, GLsizei count)
        c.glDrawArrays(
            c.GL_TRIANGLES,     // Primitve mode
            starting_index,     // Starting index in the enabled arrays
            number_of_vertices, // Number of vertices to render.
        );

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

/// TODO(devon): desc buffer usage
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

/// TODO(devon): desc gl vbo
const GlVertexBuffer = struct {
    /// TODO(devon): desc gl vbo handle 
    handle: c_uint,

    /// TODO(devon): desc gl vbo build
    pub fn build(self: *GlVertexBuffer) void {
        // glGenBuffers(GLsizei size, GLuint* buffers)
        c.glGenBuffers(1, &self.handle);
    }

    /// TODO(devon): desc gl vbo free
    pub fn free(self: *GlVertexBuffer) void {
        //glDeleteBuffer(GLsizei count, GLuint buffer))
        c.glDeleteBuffers(1, &self.handle);
    }

    /// TODO(devon): desc gl vbo bind
    pub fn bind(self: *GlVertexBuffer) void {
        // glBindBuffer(GLenum target, GLuint buffer)
        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.handle);
    }

    /// TODO(devon): desc gl vbo data
    pub fn data(self: GlVertexBuffer, vertices: []const f32, usage: GlBufferUsage) void {
        const vertices_ptr = @ptrCast(*const c_void, vertices.ptr);
        const vertices_size = @intCast(c_longlong, @sizeOf(f32) * vertices.len);

        // glBufferData(GLenum mode, Glsizeiptr size, const GLvoid* data, GLenum usage)
        c.glBufferData(c.GL_ARRAY_BUFFER, vertices_size, vertices_ptr, @enumToInt(usage));
    }
};

/// TODO(devon): desc build vbo
fn buildGlVertexBuffer(allocator: *std.mem.Allocator) anyerror!*GlVertexBuffer {
    var vbo = try allocator.create(GlVertexBuffer);

    vbo.build();

    return vbo;
}

// -----------------------------------------
//      - Vertex Array Object -
// -----------------------------------------

/// TODO(devon): desc gl vao
const GlVertexArray = struct {
    /// TODO(devon): desc gl vba handle 
    handle: c_uint,

    /// TODO(devon): desc gl vba build
    pub fn build(self: *GlVertexArray) void {
        // glGenVertexArrays(GLsizei size, GLuint* array)
        c.glGenVertexArrays(1, &self.handle);
    }

    /// TODO(devon): desc gl vba free
    pub fn free(self: *GlVertexArray) void {
        //glDeleteBuffer(GLsizei count, GLuint array))
        c.glDeleteVertexArrays(1, &self.handle);
    }

    /// TODO(devon): desc gl vba bind
    pub fn bind(self: *GlVertexArray) void {
        // glBindVertexArray(GLuint array)
        c.glBindVertexArray(self.handle);
    }

};

/// TODO(devon): desc build vba
fn buildGlVertexArray(allocator: *std.mem.Allocator) anyerror!*GlVertexArray {
    var vao = try allocator.create(GlVertexArray);

    vao.build();

    return vao;
}

// -----------------------------------------
//      - GlShaderType -
// -----------------------------------------

/// TODO(devon): desc gl shader type
pub const GlShaderType = enum(c_uint) {
    Vertex = c.GL_VERTEX_SHADER,
    Fragment = c.GL_FRAGMENT_SHADER,
    Geometry = c.GL_GEOMETRY_SHADER,
};

// -----------------------------------------
//      - GlShaders -
// -----------------------------------------

/// TODO(devon): desc glshader
const GlShader = struct {
    handle: c_uint,

    /// TODO(devon): desc gl shader build
    pub fn build(self: *GlShader, shader_type: GlShaderType) void {
        // glCreateShader(GLenum shaderType) 
        self.handle = c.glCreateShader(@enumToInt(shader_type));
    }

    /// TODO(devon): desc gl shader free
    pub fn free(self: *GlShader) void {
        //glDeleteShader(GLuint shader)
        c.glDeleteShader(self.handle);
    }

    /// TODO(devon): desc gl shader source
    pub fn source(self: *GlShader, source_string: [:0]const u8) void {
        const source_size = source_string.len;

        //glShaderSource(GLuint shader, GLsizei count, const GLchar** string, const GLint *length)
        c.glShaderSource(self.handle, 1, &source_string.ptr, @ptrCast(*const c_int, &source_size));
    }

    /// TODO(devon): desc gl shader compile
    pub fn compile(self: *GlShader) anyerror!void {
        var no_errors: c_int = undefined;
        var compilation_log: [512]u8 = undefined;

        //glCompileShader(GLuint shader)
        c.glCompileShader(self.handle);

        //glGetShaderiv(GLuint shader, GLenum pname, GLint *params)
        c.glGetShaderiv(self.handle, c.GL_COMPILE_STATUS, &no_errors);

        // If the compilation failed, log the message
        if(no_errors == 0) {
            //glGetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog)
            c.glGetShaderInfoLog(self.handle, 512, null, &compilation_log);
            std.log.err("[Renderer][OpenGL]: Failed to compile shader: \n{s}", .{compilation_log});
            return OpenGlError.ShaderCompilationFailure;

        }
    }
};

/// TODO(devon): desc build glshader
fn buildGlShader(allocator: *std.mem.Allocator, shader_type: GlShaderType) anyerror!*GlShader {
    var shader = try allocator.create(GlShader);
    
    shader.build(shader_type);

    return shader;
}

// -----------------------------------------
//      - GlShaderProgram -
// -----------------------------------------

/// TODO(devon): desc glshaderprogram
const GlShaderProgram = struct {
    handle: c_uint,

    /// TODO(devon): desc glshaderprogram build
    pub fn build(self: *GlShaderProgram) void {
        // glCreateProgram() 
        self.handle = c.glCreateProgram();
    }

    /// TODO(devon): desc glshaderprogram free
    pub fn free(self: *GlShaderProgram) void {
        //glDeleteProgram(GLuint program)
        c.glDeleteProgram(self.handle);
    }
    
    /// TODO(devon): desc glshaderprogram attach
    pub fn attach(self: *GlShaderProgram, shader: *GlShader) void {
        //glAttachShaer(GLuint program, GLuint shader)
        c.glAttachShader(self.handle, shader.*.handle);
    }

    /// TODO(devon): desc glshaderprogram link
    pub fn link(self: *GlShaderProgram) anyerror!void {
        var no_errors: c_int = undefined;
        var linking_log: [512]u8 = undefined;

        //glLinkProgram(GLuint program)
        c.glLinkProgram(self.handle);

        //glGetShaderiv(GLuint shader, GLenum pname, GLint *params)
        c.glGetProgramiv(self.handle, c.GL_LINK_STATUS, &no_errors);

        // If the linking failed, log the message
        if(no_errors == 0) {
            //glGetProgramInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog)
            c.glGetProgramInfoLog(self.handle, 512, null, &linking_log);
            std.log.err("[Renderer][OpenGL]: Failed to link shader program: \n{s}", .{linking_log});
            return OpenGlError.ShaderLinkingFailure;
        } 
    }
};

/// TODO(devon): desc build glshaderprogram
fn buildGlShaderProgram(allocator: *std.mem.Allocator) anyerror!*GlShaderProgram {
    var sp = try allocator.create(GlShaderProgram);

    sp.build();

    return sp;
}
