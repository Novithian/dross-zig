// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
const za = @import("zalgebra");

// dross-zig
const Color = @import("../../core/core.zig").Color;
const texture = @import("../texture.zig");
const TextureId = texture.TextureId;
const Sprite = @import("../sprite.zig").Sprite;
const Camera = @import("../cameras/camera_2d.zig");
const Matrix4 = @import("../../core/matrix4.zig").Matrix4;
const Vector3 = @import("../../core/vector3.zig").Vector3;
const Vector2 = @import("../../core/vector2.zig").Vector2;
const fs = @import("../../utils/file_loader.zig");
const rh = @import("../../core/resource_handler.zig");
const Application = @import("../../core/application.zig").Application;
const framebuffa = @import("../framebuffer.zig");
const Framebuffer = framebuffa.Framebuffer;

// Testing vertices and indices
// zig fmt: off
const square_vertices: [20]f32 = [20]f32{
    // Positions  / Texture coords
    // 1.0, 1.0, 0.0,  1.0, 1.0, // Top Right
    // 1.0, 0.0, 0.0,  1.0, 0.0,// Bottom Right
    // 0.0, 0.0, 0.0,  0.0, 0.0,// Bottom Left
    // 0.0, 1.0, 0.0,  0.0, 1.0,// Top Left

    0.0, 0.0, 0.0,  0.0, 0.0, // Bottom Left
    1.0, 0.0, 0.0,  1.0, 0.0,// Bottom Right
    1.0, 1.0, 0.0,  1.0, 1.0,// Top Right
    0.0, 1.0, 0.0,  0.0, 1.0,// Top Left
};
//[0  3]
//[2  1]
const square_indices: [6]c_uint = [6]c_uint{
    // 0, 1, 3,
    // 1, 2, 3,
    0, 1, 2,
    2, 3, 0
};

// zig fmt: off
const screenbuffer_vertices: [24]f32 = [24]f32{
    // Positions  / Texture coords
    -1.0,  1.0,     0.0, 1.0, // Bottom Left
    -1.0, -1.0,     0.0, 0.0,// Bottom Right
     1.0, -1.0,     1.0, 0.0,// Top Right

    -1.0,  1.0,     0.0, 1.0,// Top Left
     1.0, -1.0,     1.0, 0.0,// Top Left
     1.0,  1.0,     1.0, 1.0,// Top Left
};

// -----------------------------------------
//      - OpenGL Reference Material -
// -----------------------------------------
// OpenGL Types: https://www.khronos.org/opengl/wiki/OpenGL_Type
// Beginners:    https://learnopengl.com/Introduction

// -----------------------------------------
//      - GLSL Default Shaders -
// -----------------------------------------
const default_shader_vs: [:0]const u8 = "assets/shaders/default_shader.vs";
const default_shader_fs: [:0]const u8 = "assets/shaders/default_shader.fs";
const screenbuffer_shader_vs: [:0]const u8 = "assets/shaders/screenbuffer_shader.vs";
const screenbuffer_shader_fs: [:0]const u8 = "assets/shaders/screenbuffer_shader.fs";


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
    /// Default shader program for drawing the scene
    shader_program: ?*GlShaderProgram = undefined,
    /// Shader program for drawing the swapchain to the display
    screenbuffer_program: ?*GlShaderProgram = undefined,

    vertex_array: ?*GlVertexArray = undefined,
    vertex_buffer: ?*GlVertexBuffer = undefined,
    index_buffer: ?*GlIndexBuffer = undefined,

    screenbuffer_vertex_array: ?*GlVertexArray = undefined,
    screenbuffer_vertex_buffer: ?*GlVertexBuffer = undefined,

    clear_color: Color = undefined,
    default_draw_color: Color = undefined,

    debug_texture: ?*texture.Texture = undefined,

    screenbuffer: ?*Framebuffer = undefined,

    projection_view: ?Matrix4 = undefined,

    const Self = @This();

    /// Builds the necessary components for the OpenGL renderer
    /// Comments: INTERNAL use only. The OpenGlBackend will be the owner of the allocated memory.
    pub fn build(self: *Self, allocator: *std.mem.Allocator) anyerror!void {

        // Sets the pixel storage mode that affefcts the operation
        // of subsequent glReadPixel as well as unpacking texture patterns.
        c.glPixelStorei(c.GL_UNPACK_ALIGNMENT, 1);

        // Enable depth testing
        c.glEnable(c.GL_DEPTH_TEST);
        c.glBlendFunc(c.GL_SRC_ALPHA, c.GL_ONE_MINUS_SRC_ALPHA);

        // Allocate and compile the vertex shader
        var vertex_shader: *GlShader = try buildGlShader(allocator, GlShaderType.Vertex);
        try vertex_shader.source(default_shader_vs);
        try vertex_shader.compile();

        // Allocate and compile the vertex shader for the screenbuffer
        var screenbuffer_vertex_shader: *GlShader = try buildGlShader(allocator, GlShaderType.Vertex);
        try screenbuffer_vertex_shader.source(screenbuffer_shader_vs);
        try screenbuffer_vertex_shader.compile();

        // Allocate and compile the fragment shader
        var fragment_shader: *GlShader = try buildGlShader(allocator, GlShaderType.Fragment);
        try fragment_shader.source(default_shader_fs);
        try fragment_shader.compile();

        // Allocate and compile the vertex shader for the screenbuffer
        var screenbuffer_fragment_shader: *GlShader = try buildGlShader(allocator, GlShaderType.Fragment);
        try screenbuffer_fragment_shader.source(screenbuffer_shader_fs);
        try screenbuffer_fragment_shader.compile();
        
        // Default shader program setup
        // ---------------------------------------------------

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

        // Screenbuffer shader program setup
        // ----------------------------------------------------

        // Allocate memory for the shader program
        self.screenbuffer_program = try buildGlShaderProgram(allocator);

        // Attach the shaders to the shader program
        self.screenbuffer_program.?.attach(screenbuffer_vertex_shader);
        self.screenbuffer_program.?.attach(screenbuffer_fragment_shader);

        // Link the shader program
        try self.screenbuffer_program.?.link();

        // Allow the shader to call the OpenGL-related cleanup functions
        screenbuffer_vertex_shader.free();
        screenbuffer_fragment_shader.free();

        // Free the memory as they are no longer needed
        defer allocator.destroy(screenbuffer_vertex_shader);
        defer allocator.destroy(screenbuffer_fragment_shader);


        // Create VAO, VBO, and IB
        self.vertex_array = try buildGlVertexArray(allocator);
        self.vertex_buffer = try buildGlVertexBuffer(allocator);
        self.index_buffer = try buildGlIndexBuffer(allocator);
        self.screenbuffer_vertex_array = try buildGlVertexArray(allocator);
        self.screenbuffer_vertex_buffer = try buildGlVertexBuffer(allocator);

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

        const size_of_vatb = 5;
        const stride = @intCast(c_longlong, @sizeOf(f32) * size_of_vatb);
        const offset_position: u32 = 0;
        const offset_tex: u32 =  3 * @sizeOf(f32); // position offset(0)  + the length of the color bytes
        const index_zero: c_int = 0;
        const index_one: c_int = 1;
        const size_position: c_uint = 3;
        const size_tex_coords: c_uint = 2;

        // Tells OpenGL how to interpret the vertex data(per vertex attribute)
        // Uses the data to the currently bound VBO

        // Position Attribute
        c.glVertexAttribPointer(
            index_zero, // Which vertex attribute we want to configure
            size_position, // Size of vertex attribute (vec3 in this case)
            c.GL_FLOAT, // Type of data
            c.GL_FALSE, // Should the data be normalized?
            stride, // Stride
            @intToPtr(?*c_void, offset_position), // Offset
        );

        // Vertex Attributes are disabled by default, we need to enable them.
        c.glEnableVertexAttribArray(index_zero);

        // Texture Coordinates Attribute
        c.glVertexAttribPointer(
            index_one, // Which vertex attribute we want to configure
            size_tex_coords, // Size of vertex attribute (vec2 in this case)
            c.GL_FLOAT, // Type of data
            c.GL_FALSE, // Should the data be normalized?
            stride, // Stride
            @intToPtr(?*c_void, offset_tex), // Offset
        );

        // Enable Color Attributes
        c.glEnableVertexAttribArray(index_one);

        // Unbind the VBO
        c.glBindBuffer(c.GL_ARRAY_BUFFER, index_zero);

        // NOTE(devon): Do NOT unbind the EBO while a VAO is active as the bound
        // bound element buffer object IS stored in the VAO; keep the EBO bound.
        // Unbind the EBO

        // Setup screenbuffer VAO/VBO
        self.screenbuffer_vertex_array.?.bind();
        self.screenbuffer_vertex_buffer.?.bind();
        var screenbuffer_vertices_slice = screenbuffer_vertices[0..];
        self.screenbuffer_vertex_buffer.?.data(screenbuffer_vertices_slice, GlBufferUsage.StaticDraw);

        const screenbuffer_stride = @intCast(c_longlong, @sizeOf(f32) * 4);
        const screenbuffer_offset_tex: u32 =  2 * @sizeOf(f32); // position offset(0)  + the length of the color bytes

        c.glEnableVertexAttribArray(index_zero);

        c.glVertexAttribPointer(
            index_zero, 
            size_tex_coords,
            c.GL_FLOAT,
            c.GL_FALSE,
            screenbuffer_stride,
            @intToPtr(?*c_void, offset_position), // Offset
        );

        c.glEnableVertexAttribArray(index_one);

        c.glVertexAttribPointer(
            index_one, 
            size_tex_coords,
            c.GL_FLOAT,
            c.GL_FALSE,
            screenbuffer_stride,
            @intToPtr(?*c_void, screenbuffer_offset_tex), // Offset
        );


        // Setup framebuffers
        self.screenbuffer = try framebuffa.buildFramebuffer(allocator);
        self.screenbuffer.?.bind(framebuffa.FramebufferType.Read);
        self.screenbuffer.?.addColorAttachment(allocator, framebuffa.FramebufferAttachmentType.Color0, Vector2.new(1280, 720));
        self.screenbuffer.?.check();

        framebuffa.Framebuffer.resetFramebuffer();

        // Unbind the VAO
        c.glBindVertexArray(index_zero);

        // Set the clear color
        self.clear_color = Color.rgb(0.2, 0.2, 0.2);
        self.default_draw_color = Color.rgb(1.0, 1.0, 1.0);
 
        // TODO(devon): remove 
        // For debug purposes only
        const debug_texture_op = try rh.ResourceHandler.loadTexture("default_texture", "assets/textures/t_default.png");
        self.debug_texture = debug_texture_op orelse return texture.TextureErrors.FailedToLoad;

    }

    /// Frees up any resources that was previously allocated
    pub fn free(self: *Self, allocator: *std.mem.Allocator) void {
        // Allow for OpenGL object to de-allocate any memory it needed
        self.vertex_array.?.free();
        self.vertex_buffer.?.free();
        self.index_buffer.?.free();
        self.shader_program.?.free();
        self.screenbuffer_vertex_array.?.free();
        self.screenbuffer_vertex_buffer.?.free();
        self.screenbuffer_program.?.free();
        self.screenbuffer.?.free(allocator);

        // Free memory
        allocator.destroy(self.vertex_array.?);
        allocator.destroy(self.vertex_buffer.?);
        allocator.destroy(self.index_buffer.?);
        allocator.destroy(self.shader_program.?);
        allocator.destroy(self.screenbuffer_vertex_array.?);
        allocator.destroy(self.screenbuffer_vertex_buffer.?);
        allocator.destroy(self.screenbuffer_program.?);
        allocator.destroy(self.screenbuffer.?);
    }
    
    /// Setups up the OpenGL specific components for rendering
    pub fn beginRender(self: *Self, camera: *Camera.Camera2d) void {
        // Bind framebuffer
        self.screenbuffer.?.bind(framebuffa.FramebufferType.Both);

        // Clear the background color
        self.clearColorAndDepth();

        c.glEnable(c.GL_DEPTH_TEST);

         // Tell OpenGL which shader program's pipeline we want to use
        self.shader_program.?.use();

        const camera_pos = camera.getPosition();
        const camera_target = camera.getTargetPosition();
        const camera_direction = camera_pos.subtract(camera_target).normalize();
        const camera_right = Vector3.up().cross(camera_direction).normalize();
        const camera_up = camera_direction.cross(camera_right);
        const camera_zoom = camera.getZoom();

        // Set up projection matrix
        // const projection = Matrix4.identity().scale(Vector3.new(camera_zoom, camera_zoom, 0.0));
        const window_size = Application.getWindowSize();
        const aspect_ratio_w = window_size.getX() / window_size.getY();
        const aspect_ratio_h = window_size.getY() / window_size.getX();

        // Works well enough
        const projection = Matrix4.orthographic(
            -aspect_ratio_w, // Left
            aspect_ratio_w, // Right
            -aspect_ratio_h, // bottom
            aspect_ratio_h, // top
            -1.0, //Near
            1.0, // Far
        ); 

        // const projection = Matrix4.orthographic(
        //     0, // Left
        //     window_size.getX(), // Right
        //     window_size.getY(), // bottom
        //     0, // top
        //     -1.0, //Near
        //     1.0, // Far
        // ); 

        // const projection = Matrix4.orthographic(
        //     0.0, // Left
        //     window_size.getX(), // Right
        //     0.0, // bottom
        //     window_size.getY(), // top
        //     -1.0, //Near
        //     1.0, // Far
        // ); 

        // const projection = Matrix4.orthographic(
        //     0.0, // Left
        //     window_size.getX() * camera_zoom, // Right
        //     0.0, // bottom
        //     window_size.getY() * camera_zoom, // top
        //     -1.0, //Near
        //     1.0, // Far
        // ); 
     
        // Set up the view matrix
        // const view = Matrix4.fromTranslate(camera_pos).scale(Vector3.new(camera_zoom, camera_zoom, 0.0));
        var view = Matrix4.fromTranslate(camera_pos).scale(Vector3.new(camera_zoom, camera_zoom, 0.0));

        self.shader_program.?.setMatrix4("projection", projection);
        self.shader_program.?.setMatrix4("view", view);
    }

    /// Handles the framebuffer and clean up for the end of the user-defined render event
    pub fn endRender(self: *Self) void {
        // Bind the default frame buffer 
        framebuffa.Framebuffer.resetFramebuffer();

        // Disable depth testing
        c.glDisable(c.GL_DEPTH_TEST);

        self.clearColor();

        // Use screenbuffer's shader program
        self.screenbuffer_program.?.use();

        // Bind screen vao
        self.screenbuffer_vertex_array.?.bind();

        // Bind screenbuffer's texture
        self.screenbuffer.?.bindColorAttachment();

        // Draw the quad
        c.glDrawArrays(c.GL_TRIANGLES, 0, 6);
    }
        
    /// Sets up renderer to be able to draw a untextured quad.
    pub fn drawQuad(self: *Self, position: Vector3) void {
         // Bind Texture
        c.glBindTexture(c.GL_TEXTURE_2D, self.debug_texture.?.getGlId());

        // Translation * Rotation * Scale
        const transform = Matrix4.fromTranslate(position);

        self.shader_program.?.setMatrix4("model", transform);
        self.shader_program.?.setFloat3("sprite_color", self.default_draw_color.r, self.default_draw_color.g, self.default_draw_color.b);

        // Bind the VAO
        self.vertex_array.?.bind();
        
        self.drawIndexed(self.vertex_array.?);
    }
    
    /// Sets up renderer to be able to draw a textured quad.
    pub fn drawTexturedQuad(self: *Self, id: TextureId, position: Vector3) void {
         // Bind Texture
        c.glBindTexture(c.GL_TEXTURE_2D, id.id_gl);
        // Translation * Rotation * Scale
        const transform = Matrix4.fromTranslate(position);
        
        self.shader_program.?.setMatrix4("model", transform);
        self.shader_program.?.setFloat3("sprite_color", self.default_draw_color.r, self.default_draw_color.g, self.default_draw_color.b);


        // Bind the VAO
        self.vertex_array.?.bind();
        
        self.drawIndexed(self.vertex_array.?);
    }

    /// Sets up renderer to be able to draw a Sprite.
    pub fn drawSprite(self: *Self, sprite: *Sprite, position: Vector3) void {
        const texture_id_op = sprite.getTextureId();
        const texture_id = texture_id_op orelse {
            self.drawQuad(position);
            return;
        };
        const sprite_color = sprite.getColor();
        const sprite_scale = Vector3.fromVector2(sprite.getScale(), 1.0);
        const sprite_size_op = sprite.getSize();
        const sprite_size = sprite_size_op orelse return;
        // In pixels
        const sprite_origin = sprite.getOrigin();
        // In degrees
        const sprite_angle = sprite.getAngle();

        // Activate Texture slot and bind Texture
        c.glActiveTexture(c.GL_TEXTURE0);
        c.glBindTexture(c.GL_TEXTURE_2D, texture_id.id_gl);

        // Translation * Rotation * Scale

        // Translation
        var model = Matrix4.fromTranslate(position);

        // Rotation
        const texture_coords_x = sprite_origin.getX() / sprite_size.getX();
        const texture_coords_y = sprite_origin.getY() / sprite_size.getY();
        const model_to_origin = Vector3.new(
            texture_coords_x,
            texture_coords_y,
            0.0,
        );
        
        const origin_to_model = Vector3.new(
            -texture_coords_x,
            -texture_coords_y,
            0.0,
        );

        // Translate to the selected origin
        model = model.translate(model_to_origin);
        // Perform the rotation
        model = model.rotate(sprite_angle, Vector3.forward());
        // Translate back
        model = model.translate(origin_to_model);

        // Scaling
        model = model.scale(sprite_scale);

        self.shader_program.?.setMatrix4("model", model);
        self.shader_program.?.setVector3("sprite_color", sprite_color.toVector3());

        // Bind the VAO
        self.vertex_array.?.bind();
        
        self.drawIndexed(self.vertex_array.?);
    }

    /// Draws geometry with a index buffer
    pub fn drawIndexed(self: *Self, vertex_array: *GlVertexArray) void {
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
    pub fn clearColorAndDepth(self: *Self) void {
        c.glClearColor(self.clear_color.r, self.clear_color.g, self.clear_color.b, self.clear_color.a);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);
    }

    /// Clears the background with the set clear color and no DEPTH buffer
    pub fn clearColor(self: *Self) void {
        c.glClearColor(self.clear_color.r, self.clear_color.g, self.clear_color.b, self.clear_color.a);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
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
    pub fn source(self: *GlShader, path: [:0]const u8) anyerror!void {
        
        const source_slice = fs.loadFile(path) catch | err | {
            std.debug.print("[Shader]: Failed to load shader ({s})! {}\n", .{path, err});
            return err;
        };
        
        const source_size = source_slice.?.len;

        c.glShaderSource(self.handle, 1, &source_slice.?.ptr, @ptrCast(*const c_int, &source_size));
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

    /// Sets a uniform vec3 of `name` to the corresponding values of the group of 3 floats
    pub fn setFloat3(self: *Self, name: [*c]const u8, x: f32, y: f32, z: f32) void {
        const uniform_location = c.glGetUniformLocation(self.handle, name);
        c.glUniform3f(uniform_location, x, y, z);
    }

    /// Sets a uniform vec3 of `name` to the corresponding values of the group of 3 floats
    pub fn setVector3(self: *Self, name: [*c]const u8, vector: Vector3) void {
        const uniform_location: c_int = c.glGetUniformLocation(self.handle, name);
        const data = vector.data.to_array();
        const gl_error = c.glGetError();
        if(gl_error != c.GL_NO_ERROR){
            std.debug.print("{}\n", .{gl_error});

        }
        c.glUniform3fv(
            uniform_location,           // Location
            1,                          // Count
            @ptrCast(*const f32, &data[0]), // Data
        );
    }
    
    /// Sets a uniform mat4 of `name` to the requested `value`
    pub fn setMatrix4(self: *Self, name: [*c]const u8, matrix: Matrix4) void {
        const uniform_location = c.glGetUniformLocation(self.handle, name);
        c.glUniformMatrix4fv(
            uniform_location,   // Location
            1,                  // Count
            c.GL_FALSE,         // Transpose
            @ptrCast(*const f32, &matrix.data.data) // Data pointer
        );
        
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
