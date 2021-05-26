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
    texture: ?*Texture = 0,
    texture_coordinates: Vector2 = undefined,
    width: u32 = undefined,
    rows: u32 = undefined,
    offset_x: i32 = undefined,
    offset_y: i32 = undefined,
    x_advance: u32 = undefined,

    const Self = @This();

    ///
    pub fn build(
        allocator: *std.mem.Allocator, //
        data: [*c]u8,
        width: u32,
        rows: u32,
        offset_x: i32,
        offset_y: i32,
        x_advance: u32,
    ) !*Self {
        var glyph = try allocator.create(Glyph);
        glyph.texture = try tx.buildFontTexture(allocator, data, width, rows);
        glyph.width = width;
        glyph.rows = rows;
        glyph.offset_x = offset_x;
        glyph.offset_y = offset_y;
        glyph.x_advance = x_advance;
        return glyph;
    }

    /// 
    pub fn free(self: *Self, allocator: *std.mem.Allocator) void {
        self.texture.?.free(allocator);
        allocator.destroy(self.texture.?);
    }

    /// Sets the stored size of the glyph
    pub fn setWidth(self: *Self, width: u32) void {
        self.width = width;
    }

    /// Sets the stored size of the glyph
    pub fn setRows(self: *Self, rows: u32) void {
        self.rows = rows;
    }

    /// Sets the stored offset of the glyph
    pub fn setOffset(self: *Self, offset_x: i32, offset_y: i32) void {
        self.offset_x = offset_x;
        self.offset_y = offset_y;
    }

    /// Sets the stored x_advance of the glyph
    pub fn setAdvance(self: *Self, x_advance: u32) void {
        self.x_advance = x_advance;
    }

    /// Returns the stored width of the glyph
    pub fn getWidth(self: *Self) u32 {
        return self.width;
    }

    /// Returns the stored number of rows of the glyph
    pub fn getRows(self: *Self) u32 {
        return self.rows;
    }

    /// Returns the stored offset of the glyph
    pub fn getOffset(self: *Self) Vector2 {
        return Vector2.new(
            @intToFloat(f32, self.offset_x),
            @intToFloat(f32, self.offset_y),
        );
    }

    /// Returns the stored x_advance of the glyph
    pub fn getAdvance(self: *Self) u32 {
        return self.x_advance;
    }

    /// Returns a pointer to the glyph's texture
    pub fn getTexture(self: *Self) ?*Texture {
        return self.texture;
    }
};
