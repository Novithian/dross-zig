// Third Parties
const std = @import("std");
const c = @import("../../c_global.zig").c_imp;
// dross-zig
const Vector2 = @import("../../core/vector2.zig").Vector2;
const fs = @import("../../utils/file_loader.zig");
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - FontLibrary -
// -----------------------------------------

///
pub const FontLibrary = struct {
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
pub fn buildFontLibrary(allocator: *std.mem.Allocator) !*FontLibrary {
    var renderer = try allocator.create(FontLibrary);

    renderer.build(allocator);

    return renderer;
}
