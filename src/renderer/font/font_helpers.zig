// Third Parties
const std = @import("std");
const c = @import("../../c_global.zig").c_imp;
// dross-zig
const app = @import("../../core/application.zig");
const gly = @import("glyph.zig");
const Glyph = gly.Glyph;
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - Font Helpers -
// -----------------------------------------

/// Returns the width of the string `text` with scaling of `scale` 
/// using the currently set Font.
pub fn getStringWidth(text: []const u8, scale: f32) f32 {
    const text_length = text.len;
    var index: usize = 0;
    var total_width: f32 = 0;

    while (index < text_length) : (index += 1) {
        const character: u8 = text[index];
        const glyph = app.default_font.?.glyph(character) catch |err| {
            std.debug.print("[Font]: Error occurred when retrieving glyph {}! {}\n", .{ character, err });
            @panic("[Font]: Failed to find glyph!");
        };

        const advance = glyph.advance();

        const shifted = @intToFloat(f32, (advance >> 6)) * scale;
        total_width += shifted;
    }

    return total_width;
}

/// Returns the height of the tallest glyph in the string `text` with scaling of `scale` 
/// using the currently set Font.
pub fn getStringHeight(text: []const u8, scale: f32) f32 {
    const text_length = text.len;
    var index: usize = 0;
    var tallest: f32 = 0;

    while (index < text_length) : (index += 1) {
        const character: u8 = text[index];
        const glyph = app.default_font.?.glyph(character) catch |err| {
            std.debug.print("[Font]: Error occurred when retrieving glyph {}! {s}\n", .{ character, err });
            @panic("[Font]: Failed to find glyph!");
        };

        const glyph_height = @intToFloat(f32, glyph.rows());
        const height = glyph_height * scale;
        if (tallest < height) tallest = height;
    }

    return tallest;
}
