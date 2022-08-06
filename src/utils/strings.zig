// Third Parties
const std = @import("std");
// dross-zig
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - String -
// -----------------------------------------

pub fn format(buffer: []u8, comptime fmt: []const u8, args: anytype) []const u8 {
    var string: []const u8 = std.fmt.bufPrint(buffer, fmt, args) catch |err| {
        std.debug.print("[String]: Formatting encountered an error! {}\n", .{err});
        @panic("[String]: Error occurred while formatting!\n");
    };
    return string;
}
