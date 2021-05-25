// Third Parties
const std = @import("std");
const c = @import("../../c_global.zig").c_imp;
// dross-zig
const Vector2 = @import("../../core/vector2.zig").Vector2;
const fs = @import("../../utils/file_loader.zig");
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - FontRenderer -
// -----------------------------------------

///
pub const FontRenderer = struct {
    const Self = @This();

    ///
    pub fn build(self: *Self, allocator: *std.mem.Allocator) void {
        //
    }

    ///
    pub fn free() void {
        //
    }
};

///
pub fn buildFontRenderer(allocator: *std.mem.Allocator) !*FontRenderer {
    var renderer = try allocator.create(FontRenderer);

    renderer.build(allocator);

    return renderer;
}
