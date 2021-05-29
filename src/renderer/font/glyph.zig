// Third Parties
const std = @import("std");
const c = @import("../../c_global.zig").c_imp;
// dross-zig
const Vector2 = @import("../../core/vector2.zig").Vector2;
const tx = @import("../texture.zig");
const Texture = tx.Texture;
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - Glyph -
// -----------------------------------------

///
pub const Glyph = struct {
    internal_texture: ?*Texture = 0,
    texture_coordinates: Vector2 = undefined,
    internal_width: u32 = undefined,
    internal_rows: u32 = undefined,
    internal_offset_x: i32 = undefined,
    internal_offset_y: i32 = undefined,
    internal_advance: u32 = undefined,

    const Self = @This();

    /// Allocates and builds a Glyph instance
    /// Comments: The Font instance should be the 
    /// only player this is called, so the owner 
    /// SHOULD be a Font instance.
    pub fn new(
        allocator: *std.mem.Allocator,
        data: [*c]u8,
        desired_width: u32,
        desired_rows: u32,
        desired_offset_x: i32,
        desired_offset_y: i32,
        desired_advance: u32,
    ) !*Self {
        var glyph = try allocator.create(Glyph);
        glyph.internal_texture = try tx.buildFontTexture(allocator, data, desired_width, desired_rows);
        glyph.internal_width = desired_width;
        glyph.internal_rows = desired_rows;
        glyph.internal_offset_x = desired_offset_x;
        glyph.internal_offset_y = desired_offset_y;
        glyph.internal_advance = desired_advance;
        return glyph;
    }

    /// Cleans up and de-allocates the Glyph and 
    /// any memory it allocated.
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        self.internal_texture.?.free(allocator);
        allocator.destroy(self.internal_texture.?);
        allocator.destroy(self);
    }

    /// Sets the stored size of the glyph
    pub fn setWidth(self: *Self, width: u32) void {
        self.internal_width = width;
    }

    /// Sets the stored size of the glyph
    pub fn setRows(self: *Self, rows: u32) void {
        self.internal_rows = rows;
    }

    /// Sets the stored offset of the glyph
    pub fn setOffset(self: *Self, offset_x: i32, offset_y: i32) void {
        self.internal_offset_x = offset_x;
        self.internal_offset_y = offset_y;
    }

    /// Sets the stored x_advance of the glyph
    pub fn setAdvance(self: *Self, x_advance: u32) void {
        self.internal_advance = x_advance;
    }

    /// Returns the stored width of the glyph
    pub fn width(self: *Self) u32 {
        return self.internal_width;
    }

    /// Returns the stored number of rows of the glyph
    pub fn rows(self: *Self) u32 {
        return self.internal_rows;
    }

    /// Returns the stored offset of the glyph
    pub fn offset(self: *Self) Vector2 {
        return Vector2.new(
            @intToFloat(f32, self.internal_offset_x),
            @intToFloat(f32, self.internal_offset_y),
        );
    }

    /// Returns the stored x_advance of the glyph
    pub fn advance(self: *Self) u32 {
        return self.internal_advance;
    }

    /// Returns a pointer to the glyph's texture
    pub fn texture(self: *Self) ?*Texture {
        return self.internal_texture;
    }
};
