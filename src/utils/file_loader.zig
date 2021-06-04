// Third Parties
const std = @import("std");
// dross-zig
// ------------------------------------------------

// -----------------------------------------
//      - FileLoader -
// -----------------------------------------
/// The possible errors that may occur when loading files.
pub const FileLoaderErrors = error{
    // In WASI, this error may occur when the file descriptor does not hold the required rights to seek on it.
    AccessDenied,
    // The Operating System returned an undocumented error code. This error is in theory not possible, but it would be better to handle this error than to invoke undefined behavior.
    Unexpected,
    Unseekable,
};

/// Loads a file and returns a slice of the bytes. 
/// Path is relative to the zig.build/exe.
/// If an error occurs, it'll return null.
pub fn loadFile(path: []const u8, comptime buffer_size: usize) !?[]const u8 {

    // Get the source file
    const file = try std.fs.cwd().openFile(
        path,
        .{},
    );

    defer file.close();

    // Create a buffer to store the file read in
    var file_buffer: [buffer_size]u8 = undefined;

    try file.seekTo(0);

    const source_bytes = try file.readAll(&file_buffer);
    return file_buffer[0..source_bytes];
}
