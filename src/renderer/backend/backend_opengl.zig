// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
const za = @import("zalgebra");

// dross-zig
const Color = @import("../../core/core.zig").Color;
const texture = @import("../texture.zig");
const Camera = @import("../cameras/camera_2d.zig");
const Matrix4 = @import("../../core/matrix4.zig").Matrix4;
const Vector3 = @import("../../core/vector3.zig").Vector3;

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
/// Comments: This is for INTERNAL use only. 
pub const OpenGlBackend = struct {
    shader_program: ?*GlShaderProgram,
    vertex_array: ?*GlVertexArray,
    vertex_buffer: ?*GlVertexBuffer,
    index_buffer: ?*GlIndexBuffer,

    clear_color: Color,

    debug_texture: ?*texture.Texture,

    projection_view: ?Matrix4,

    const Self = @This();

    /// Builds the necessary components for the OpenGL renderer
    /// Comments: INTERNAL use only. The OpenGlBackend will be the owner of the allocated memory.
    pub fn build(self: *Self, allocator: *std.mem.Allocator) anyerror!void {

        // Sets the pixel storage mode that affefcts the operation
        // of subsequent glReadPixel as well as unpacking texture patterns.
        c.glPixelStorei(c.GL_UNPACK_ALIGNMENT, 1);

        // Enable depth testing
        c.glEnable(c.GL_DEPTH_TEST);

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


        // Set the clear color
        self.clear_color = Color.rgb(0.2, 0.2, 0.2);

        // TODO(devon): remove 
        // For debug purposes only
        self.debug_texture = try texture.buildTexture(allocator);

    }

    /// Frees up any resources that was previously allocated
    pub fn free(self: *Self, allocator: *std.mem.Allocator) void {
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
    
    /// Setups up the OpenGL specific components for rendering
    pub fn beginRender(self: *Self, camera: *Camera.Camera2d) void {
        // Clear the background color
        self.clear();

         // Tell OpenGL which shader program's pipeline we want to use
        self.shader_program.?.use();

        // Set up projection_view matrix
        self.projection_view = Matrix4.identity();
        // NOTE(devon): In Orthographic mode, the projection will be just an identity matrix.
        // Making the projection_view matrix nothing more than a simple translation matrix.
        const projection_view_location: c_int = c.glGetUniformLocation(self.shader_program.?.handle, "projection_view");

        c.glUniformMatrix4fv(
            projection_view_location,  // Location
            1,                  // count
            c.GL_FALSE,         // transpose from column-major to row-major
            @ptrCast(*const f32, &self.projection_view)// data
        );
    }
        

    pub fn drawQuad(self: *Self, position: Vector3) void {
         // Bind Texture
        c.glBindTexture(c.GL_TEXTURE_2D, self.debug_texture.?.getGlId());
        // Translation * Rotation * Scale
        const transform = Matrix4.fromTranslate(position);
        
        const model_location: c_int = c.glGetUniformLocation(self.shader_program.?.handle, "model");
        c.glUniformMatrix4fv(
            model_location,  // Location
            1,                  // count
            c.GL_FALSE,         // transpose from column-major to row-major
            @ptrCast(*const f32, &transform.data)// data
        );

        // Bind the VAO
        self.vertex_array.?.bind();
        
        self.drawIndexed(self.vertex_array.?);
    }


    /// Draws geometry with a index buffer
    pub fn drawIndexed(self: *Self, vertex_array: *GlVertexArray) void {
        const number_of_vertices: i32 = 6;
        const offset = @intToPtr(?*c_void, 0);

        // Draw 
        c.glDrawElements(
            c.GL_TRIANGLES, // Primitive mode
            6, // Number of vertices/elements to draw
            c.GL_UNSIGNED_INT, // Type of values in indices
            offset, // Offset in a buffer or a pointer to the location where the indices are stored
        );
    }
    
    
    /// Clears the background with the set clear color
    pub fn clear(self: *Self) void {
        c.glClearColor(self.clear_color.r, self.clear_color.g, self.clear_color.b, self.clear_color.a);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);
    }
};

/// Resizes the viewport to the given size and position 
/// Comments: This is for INTERNAL use only.
pub fn resizeViewport(x: c_int, y: c_int, width: c_int, height: c_int) void {
    c.glViewport(x, y, width, height);
}

/// Allocates the appropriate backend graphics api and calls the GLAD specific code required for setting up
/// Comments: Owned by the caller. This is for INTERNAL use only.
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
    pub fn build(self: *GlVertexBuffer) void {
        c.glGenBuffers(1, &self.handle);
    }

    /// Frees the Vertex Buffer
    pub fn free(self: *GlVertexBuffer) void {
        c.glDeleteBuffers(1, &self.handle);
    }

    /// Binds the Vertex Buffer to the current buffer target.
    pub fn bind(self: *GlVertexBuffer) void {
        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.handle);
    }

    /// Allocates memory and stores data within the the currently bound buffer object.
    pub fn data(self: GlVertexBuffer, vertices: []const f32, usage: GlBufferUsage) void {
        const vertices_ptr = @ptrCast(*const c_void, vertices.ptr);
        const vertices_size = @intCast(c_longlong, @sizeOf(f32) * vertices.len);

        c.glBufferData(c.GL_ARRAY_BUFFER, vertices_size, vertices_ptr, @enumToInt(usage));
    }
};

/// Allocates a vertex buffer and sets it up
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
    pub fn build(self: *GlIndexBuffer) void {
        c.glGenBuffers(1, &self.handle);
    }

    /// Frees the Index Buffer
    pub fn free(self: *GlIndexBuffer) void {
        c.glDeleteBuffers(1, &self.handle);
    }

    /// Binds the Index Buffer
    pub fn bind(self: *GlIndexBuffer) void {
        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, self.handle);
    }

    /// Allocates memory and stores data within the the currently bound buffer object.
    pub fn data(self: GlIndexBuffer, indices: []const c_uint, usage: GlBufferUsage) void {
        const indices_ptr = @ptrCast(*const c_void, indices.ptr);
        const indices_size = @intCast(c_longlong, @sizeOf(c_uint) * indices.len);

        c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, indices_size, indices_ptr, @enumToInt(usage));
    }
};

/// Allocates an Index Buffer and sets it up
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
    pub fn build(self: *GlVertexArray) void {
        c.glGenVertexArrays(1, &self.handle);
    }

    /// Frees the OpenGL generated handle
    pub fn free(self: *GlVertexArray) void {
        c.glDeleteVertexArrays(1, &self.handle);
    }

    /// Binds the Vertex Array
    pub fn bind(self: *GlVertexArray) void {
        c.glBindVertexArray(self.handle);
    }
};

/// Allocates an Vertex Array and sets it up
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
    pub fn build(self: *GlShader, shader_type: GlShaderType) void {
        self.handle = c.glCreateShader(@enumToInt(shader_type));
        self.shader_type = shader_type;
    }

    /// Frees the stored shader handle
    pub fn free(self: *GlShader) void {
        c.glDeleteShader(self.handle);
    }

    /// Sources a given GLSL shader file
    pub fn source(self: *GlShader, filename: [:0]const u8) anyerror!void {
        // Open the shader directory
        var dir = try std.fs.cwd().openDir(
            //"src/renderer/shaders",
            "resources/shaders",
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

        c.glShaderSource(self.handle, 1, &source_slice.ptr, @ptrCast(*const c_int, &source_size));
    }

    /// Compiles the previously sources GLSL shader file, and checks for any compilation errors.
    pub fn compile(self: *GlShader) anyerror!void {
        var no_errors: c_int = undefined;
        var compilation_log: [512]u8 = undefined;

        c.glCompileShader(self.handle);

        c.glGetShaderiv(self.handle, c.GL_COMPILE_STATUS, &no_errors);

        // If the compilation failed, log the message
        if (no_errors == 0) {
            c.glGetShaderInfoLog(self.handle, 512, null, &compilation_log);
            std.log.err("[Renderer][OpenGL]: Failed to compile {s} shader: \n{s}", .{ self.shader_type, compilation_log });
            return OpenGlError.ShaderCompilationFailure;
        }
    }
};

/// Allocates an GlShader and sets it up
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
    pub fn build(self: *Self) void {
        self.handle = c.glCreateProgram();
    }

    /// Frees the OpenGL reference
    pub fn free(self: *Self) void {
        c.glDeleteProgram(self.handle);
    }

    /// Attaches the requested shader to be used for rendering
    pub fn attach(self: *Self, shader: *GlShader) void {
        c.glAttachShader(self.handle, shader.*.handle);
    }

    /// Links the shader program and checks for any errors
    pub fn link(self: *Self) anyerror!void {
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
    pub fn setBool(self: *Self, name: [:0]const u8, value: bool) void {
        const uniform_location = c.glGetUniformLocation(self.handle, &name.ptr);
        const int_value: c_int = @as(c_int, value);
        c.glUniform1i(uniform_location, int_value);
    }

    /// Sets a uniform integer of `name` to the requested `value`
    pub fn setInt(self: *Self, name: [:0]const u8, value: i32) void {
        const uniform_location = c.glGetUniformLocation(self.handle, &name.ptr);
        const int_value: c_int = @as(c_int, value);
        c.glUniform1i(uniform_location, int_value);
    }

    /// Sets a uniform float of `name` to the requested `value`
    pub fn setFloat(self: *Self, name: [:0]const u8, value: f32) void {
        const uniform_location = c.glGetUniformLocation(self.handle, &name.ptr);
        c.glUniform1f(uniform_location, value);
    }
};

/// Allocates an GlShaderProgram and sets it up
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
