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
    offset_x: u32 = undefined,
    offset_y: u32 = undefined,
    x_advance: u32 = undefined,

    const Self = @This();

    ///
    pub fn build(
        allocator: *std.mem.Allocator, //
        data: [*c]u8,
        width: u32,
        rows: u32,
        offset_x: u32,
        offset_y: u32,
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
    pub fn setWidth(self: *self, width: u32) void {
        self.size = size;
    }

    /// Sets the stored size of the glyph
    pub fn setRows(self: *self, rows: u32) void {
        self.rows = rows;
    }

    /// Sets the stored offset of the glyph
    pub fn setOffset(self: *self, offset_x: u32, offset_y: u32) void {
        self.offset_x = offset_x;
        self.offset_y = offset_y;
    }

    /// Sets the stored x_advance of the glyph
    pub fn setAdvanceX(self: *self, x_advance: u32) void {
        self.x_advance = x_advance;
    }
};
