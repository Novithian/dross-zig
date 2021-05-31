// Third Parties
const std = @import("std");
const c = @import("../../c_global.zig").c_imp;
// dross-zig
const Vector2 = @import("../../core/vector2.zig").Vector2;
const Renderer = @import("../renderer.zig").Renderer;
const PackingMode = @import("../renderer.zig").PackingMode;
const ByteAlignment = @import("../renderer.zig").ByteAlignment;
const fs = @import("../../utils/file_loader.zig");
const gly = @import("glyph.zig");
const Glyph = gly.Glyph;
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - Font -
// -----------------------------------------

///
pub const Font = struct {
    glyphs: std.AutoHashMap(u32, *Glyph),

    // FreeType
    library: ?*c.FT_Library,
    face: ?*c.FT_Face,

    const Self = @This();

    /// Creates a new Font instance
    /// Comments: The caller should only be going through the Resource Handler.
    /// The Resource Handler will automatically handle de-allocating.
    pub fn new(allocator: *std.mem.Allocator, path: [*c]const u8) !*Self {
        var self = try allocator.create(Font);

        // Allocate the memory block for the Font Library
        self.library = allocator.create(c.FT_Library) catch |err| {
            std.debug.print("[Font]: Error occurred while creating font library for {s}! {s}\n", .{ path, err });
            @panic("[Font]: Error occurred while creating font!\n");
        };
        // Initialize the Font Library
        const library_error = c.FT_Init_FreeType(self.library.?);
        if (library_error != 0) @panic("[Font]: Error occurred when initializing FreeType Library!");

        // Allocate the memory block for the Font Face
        self.face = allocator.create(c.FT_Face) catch |err| {
            std.debug.print("[Font]: Error occurred while creating font face for {s}! {s}\n", .{ path, err });
            @panic("[Font]: Error occurred while creating font!\n");
        };
        // Initialize the Font Face
        const face_error = c.FT_New_Face(self.library.?.*, path, 0, self.face.?);
        if (face_error != 0) @panic("[Font]: Error occurred when initializing FreeType Face!");

        // Set the font's pixel size
        // NOTE(devon): Giving it a pixel width of 0 will force it to be dynamically calculated.
        const pixel_size_error = c.FT_Set_Pixel_Sizes(self.face.?.*, 0, 24); // face, pixel_width, pixel_height
        if (pixel_size_error != 0) @panic("[Font]: Error occurred when setting the pixel size!");

        // Set the unpack byte alignment to 1 byte
        Renderer.setByteAlignment(PackingMode.Unpack, ByteAlignment.One);

        // Initialize the glyph hashmap
        self.glyphs = std.AutoHashMap(u32, *Glyph).init(allocator);

        // Loop through and setup the glyphs
        const number_of_glyphs = 128;
        const start_offset = 32;
        var character: u32 = start_offset;
        while (character < start_offset + number_of_glyphs) : (character += 1) {
            // Load the glyph
            const char_load_error = c.FT_Load_Char(self.face.?.*, @intCast(c_ulong, character), c.FT_LOAD_RENDER);
            if (char_load_error != 0) @panic("[Font]: Error occurred when loading glyph!");
            const glyph_width = @intCast(u32, self.face.?.*.*.glyph.*.bitmap.width);
            const glyph_rows = @intCast(u32, self.face.?.*.*.glyph.*.bitmap.rows);
            const glyph_offset_x = @intCast(i32, self.face.?.*.*.glyph.*.bitmap_left);
            const glyph_offset_y = @intCast(i32, self.face.?.*.*.glyph.*.bitmap_top);
            const glyph_x_advance = @intCast(u32, self.face.?.*.*.glyph.*.advance.x);
            const buffer_data = self.face.?.*.*.glyph.*.bitmap.buffer;

            // Generate Texture
            var new_glyph = try Glyph.new(allocator, buffer_data, glyph_width, glyph_rows, glyph_offset_x, glyph_offset_y, glyph_x_advance);

            //// Add glyph to the list
            try self.glyphs.put(character, new_glyph);
        }

        Renderer.clearBoundTexture();

        return self;
    }

    /// Cleans up and de-allocates any memory in regards to the Font instance.
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        _ = c.FT_Done_Face(self.face.?.*);
        _ = c.FT_Done_FreeType(self.library.?.*);

        var glyph_iter = self.glyphs.iterator();

        while (glyph_iter.next()) |entry| {
            var glyph_entry = self.glyphs.remove(entry.key);

            Glyph.free(allocator, glyph_entry.?.value);
        }

        self.glyphs.deinit();

        allocator.destroy(self.face.?);
        allocator.destroy(self.library.?);

        allocator.destroy(self);
    }

    /// Returns a pointer to the glyph
    pub fn glyph(self: *Self, character: u8) !*Glyph {
        return self.glyphs.get(@intCast(c_ulong, character)).?;
    }
};
