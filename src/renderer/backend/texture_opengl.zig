// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
const zigimg = import("zigimg");
// dross-zig
const InternalTexture = @import("../texture.zig").InternalTexture;
const TextureErrors = @import("../texture.zig").TextureErrors;
const apis = @import("../renderer.zig").BackendApi;
const fs = @import("../../utils/file_loader.zig");
const Vector2 = @import("../../core/vector2.zig").Vector2;

// -----------------------------------------
//      - TextureGl -
// -----------------------------------------

/// OpenGL implmentation for image data
pub const TextureGl = struct {
    /// OpenGl generated ID for the texture
    // NOTE(devon): 0 is not a valid ID!
    internal_id: c_uint = 0,
    /// The stored image data
    // data: [:0]const u8 = undefined,
    /// The width of the texture
    internal_width: c_int = 0,
    /// The height of the texture
    internal_height: c_int = 0,
    /// The number of channels used in the texture
    internal_channels: c_int = 0,

    const Self = @This();

    /// Builds the TextureGl object and allocates any required memory
    /// Comments: The caller (Texture) will own the allocated memory.
    pub fn new(allocator: *std.mem.Allocator, path: []const u8) !*Self {
        var self = try allocator.create(TextureGl);

        const number_of_textures: c_int = 1;
        const mipmap_level: c_int = 0;
        const border: c_int = 0;

        c.stbi_set_flip_vertically_on_load(1);

        // Generate texture ID
        c.glGenTextures(number_of_textures, @ptrCast(*c_uint, &self.internal_id));

        // Bind the texture
        c.glBindTexture(c.GL_TEXTURE_2D, self.internal_id);

        // Set texture parameters
        // NOTE(devon): Test image is pixel art, so we're defaulting to
        // nearest texture filtering
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_CLAMP_TO_EDGE);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_CLAMP_TO_EDGE);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);

        //var compressed_bytes: []const u8 = @embedFile("../../../assets/sprites/s_guy_idle.png");
        var compressed_bytes: ?[]const u8 = fs.loadFile(path, 4 * 1024 * 1024) catch |err| {
            std.debug.print("[Texture]: Failed to load Texture at {s}! {}\n", .{ path, err });
            return err;
        };

        const bytes_length: c_int = @intCast(c_int, compressed_bytes.?.len);

        // Determine if the file is a png file
        if (c.stbi_info_from_memory(compressed_bytes.?.ptr, bytes_length, &self.internal_width, &self.internal_height, &self.internal_channels) == 0) {
            return error.NotPngFile;
        }

        // Ensure that the image has pixel data
        if (self.internal_width <= 0 or self.internal_height <= 0) return error.NoPixels;

        if (c.stbi_is_16_bit_from_memory(compressed_bytes.?.ptr, bytes_length) != 0) {
            return error.InvalidFormat;
        }

        const bits_per_channel = 8;
        const channel_count = 4;

        const width_u32 = @intCast(u32, self.internal_width);
        const height_u32 = @intCast(u32, self.internal_height);

        const image_data = c.stbi_load_from_memory(compressed_bytes.?.ptr, bytes_length, &self.internal_width, &self.internal_height, &self.internal_channels, channel_count);

        if (image_data == null) return error.NoMem;

        const pitch = width_u32 * bits_per_channel * channel_count / 8;
        var data = image_data[0 .. height_u32 * pitch];

        // Generate gl texture
        c.glTexImage2D(
            c.GL_TEXTURE_2D, // Texture Target
            mipmap_level, // mipmap detail level
            c.GL_RGBA, // Specifies the number of color components in texture
            self.internal_width, // Width of image
            self.internal_height, // Height of image
            border, // Boarde NOTE(devon): must be 0
            c.GL_RGBA, // Specifies the format of the pixel data
            c.GL_UNSIGNED_BYTE, // Specifies the data type of the pixel data
            @ptrCast(*c_void, &data.ptr[0]), // void pointer to image data
        );

        // Generate mipmap
        // c.glGenerateMipmap(c.GL_TEXTURE_2D);

        c.stbi_image_free(data.ptr);

        return self;
    }

    /// Builds a dataless TextureGl object and allocates any required memory
    /// Comments: The caller (Texture) will own the allocated memory.
    pub fn newDataless(allocator: *std.mem.Allocator, size: Vector2) !*Self {
        var self = try allocator.create(TextureGl);

        // Generate texture ID
        c.glGenTextures(1, @ptrCast(*c_uint, &self.internal_id));

        // Bind the texture
        c.glBindTexture(c.GL_TEXTURE_2D, self.internal_id);

        // Set texture parameters
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);

        self.internal_width = @floatToInt(c_int, size.x());
        self.internal_height = @floatToInt(c_int, size.y());

        // Generate gl texture
        c.glTexImage2D(
            c.GL_TEXTURE_2D, // Texture Target
            0, // mipmap detail level
            c.GL_RGB, // Specifies the number of color components in texture
            self.internal_width, // Width of image
            self.internal_height, // Height of image
            0, // Boarde NOTE(devon): must be 0
            c.GL_RGB, // Specifies the format of the pixel data
            c.GL_UNSIGNED_BYTE, // Specifies the data type of the pixel data
            null, // void pointer to image data
        );

        return self;
    }

    /// Builds the TextureGl object for font rendering and allocates any required memory
    /// Comments: The caller (Texture) will own the allocated memory.
    pub fn newFont(allocator: *std.mem.Allocator, data: [*c]u8, desired_width: u32, desired_rows: u32) !*Self {
        var self = try allocator.create(TextureGl);

        // Generate texture ID
        c.glGenTextures(1, @ptrCast(*c_uint, &self.internal_id));

        // Bind the texture
        c.glBindTexture(c.GL_TEXTURE_2D, self.internal_id);

        // Set texture parameters
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_CLAMP_TO_BORDER);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_CLAMP_TO_BORDER);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);

        self.internal_width = @intCast(c_int, desired_width);
        self.internal_height = @intCast(c_int, desired_rows);

        // Generate gl texture
        c.glTexImage2D(
            c.GL_TEXTURE_2D, // Texture Target
            0, // mipmap detail level
            c.GL_RED, // Specifies the number of color components in texture
            self.internal_width, // Width of image
            self.internal_height, // Height of image
            0, // Boarde NOTE(devon): must be 0
            c.GL_RED, // Specifies the format of the pixel data
            c.GL_UNSIGNED_BYTE, // Specifies the data type of the pixel data
            @ptrCast(?*const c_void, data), // void pointer to image data
        );

        return self;
    }

    /// Frees the allocated memory that OpenGlTexture required to function. 
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        c.glDeleteTextures(1, @ptrCast(*c_uint, &self.internal_id));

        allocator.destroy(self);
    }

    /// Binds the texture
    pub fn bind(self: *Self) void {
        c.glBindTexture(c.GL_TEXTURE_2D, self.internal_id);
    }

    /// Binds the texture
    pub fn bindUnit(slot_index: c_uint, external_id: c_uint) void {
        c.glBindTextureUnit(slot_index, external_id);
    }

    /// Returns the OpenGL generated texture id
    pub fn id(self: *Self) c_uint {
        if (self.internal_id == 0) @panic("[Renderer][OpenGL]: Texture ID of 0 is NOT valid!");
        return self.internal_id;
    }

    /// Returns the stored height of the texture
    pub fn height(self: *Self) c_int {
        return self.internal_height;
    }

    /// Returns the stored width of the texture
    pub fn width(self: *Self) c_int {
        return self.internal_width;
    }
};
