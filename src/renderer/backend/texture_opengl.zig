// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
// dross-zig
const InternalTexture = @import("../texture.zig").InternalTexture;
const apis = @import("../renderer.zig").BackendApi;

// -----------------------------------------
//      - OpenGlTexture -
// -----------------------------------------

/// OpenGL implmentation for image data
pub const OpenGlTexture = struct {
    /// OpenGl generated ID for the texture
    // NOTE(devon): 0 is not a valid ID!
    id: c_uint = 0,
    /// The stored image data
    // data: [:0]const u8 = undefined,
    /// The width of the texture
    width: c_int = 0,
    /// The height of the texture
    height: c_int = 0,
    /// The number of channels used in the texture
    channels: c_int = 0,
    data: []u8,

    const Self = @This();

    /// Builds the OpenGLTexture object and allocates any required memory
    /// Returns: anyerror!void
    pub fn build(self: *Self) anyerror!void {
        const number_of_textures: c_int = 1;
        const desired_channels: c_int = 0;
        const mipmap_level: c_int = 0;
        const border: c_int = 0;

        // Generate texture ID
        // glGenTexture(GLsizei n, GLuint* textures)
        c.glGenTextures(number_of_textures, @ptrCast(*c_uint, &self.id));

        // Bind the texture
        c.glBindTexture(c.GL_TEXTURE_2D, self.id);

        // Set texture parameters
        // NOTE(devon): Test image is pixel art, so we're defaulting to
        // nearest texture filtering
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);

        var compressed_bytes: []const u8 = @embedFile("../../../assets/sprites/s_guy_idle.png");
        const bytes_length: c_int = @intCast(c_int, compressed_bytes.len);
        // Determine if the file is a png file
        if(c.stbi_info_from_memory(compressed_bytes.ptr, bytes_length, &self.width, &self.height, null) == 0){
            return error.NotPngFile;
        }

        // Ensure that the image has pixel data
        if(self.width <= 0 or self.height <= 0) return error.NoPixels;

        if(c.stbi_is_16_bit_from_memory(compressed_bytes.ptr, bytes_length) != 0) {
            return error.InvalidFormat;
        }

        const bits_per_channel = 8;
        const channel_count = 4;

        const width = @intCast(u32, self.width);
        const height = @intCast(u32, self.height);

        c.stbi_set_flip_vertically_on_load(1);

        const image_data = c.stbi_load_from_memory(compressed_bytes.ptr, bytes_length, &self.width, &self.height, null, channel_count);

        if(image_data == null) return error.NoMem;

        const pitch = width * bits_per_channel * channel_count / 8;
        self.data = image_data[0.. height * pitch];


        // Load the data from the image
        // var data = c.stbi_load(
        //     // "../../../assets/sprites/s_guy_idle.png", // Image Path
        //     "assets/sprites/s_guy_idle.png", // Image Path
        //     &self.width, 
        //     &self.height,
        //     &self.channels,
        //     // @ptrCast(*c_int, &self.width), // pointer to width address
        //     // @ptrCast(*c_int, &self.height), // pointer to height address
        //     // @ptrCast(*c_int, &self.channels), // pointer to channels address
        //     c.STBI_rgb_alpha, // desired channels
        // );
        // const data = c.stbi_load_from_memory(

        // );

        c.glPixelStorei(c.GL_UNPACK_ALIGNMENT, 4);

        // Generate gl texture

        // glTexImage2D(GLenumn target, GLint, level,
        //              GLint internal_format, GLsizei width,
        //              GLsizei height, GLint border,
        //              GLenum format, GLenum type,
        //              const GLvoid* data)
        c.glTexImage2D(
            c.GL_TEXTURE_2D, // Texture Target
            mipmap_level, // mipmap detail level
            c.GL_RGBA, // Specifies the number of color components in texture
            self.width, // Width of image
            self.height, // Height of image
            border, // Boarde NOTE(devon): must be 0
            c.GL_RGBA, // Specifies the format of the pixel data
            c.GL_UNSIGNED_BYTE, // Specifies the data type of the pixel data
            @ptrCast(*c_void, &self.data.ptr[0]), // void pointer to image data
        );

        // Generate mipmap
        c.glGenerateMipmap(c.GL_TEXTURE_2D);
    }

    /// TODO(devon): opengl texture free
    pub fn free(self: *Self, allocator: *std.mem.Allocator) void {
        c.stbi_image_free(self.data.ptr);
    }

    /// TODO(devon): opengl texture id
    pub fn id(self: *Self) c_uint {
        if(self.id == 0) @panic("[Renderer][OpenGL]: Texture ID of 0 is NOT valid!");
        return self.id;
    }
};

/// Allocates and builds the Opengl
/// Returns: anyerror!*OpenGlTexture
/// allocator: *std.mem.Allocator - The allocator to allocate a memory block for the texture
/// Comments: The dross-zig Texture owns the Texture
pub fn buildOpenGlTexture(allocator: *std.mem.Allocator) anyerror!*OpenGlTexture {
    // var internal_texture: *InternalTexture = try allocator.create(InternalTexture);
    var internal_texture: *OpenGlTexture = try allocator.create(OpenGlTexture);
    // internal_texture.OpenGl = try.allocator.create(OpenGLTexture);
    try internal_texture.build();

    return internal_texture;
}
