// Third-Party
const std = @import("std");
const c = @import("../c_global.zig").c_imp;
// Dross-zig
// ------------------------------------

// -----------------------------------------
//      - AudioPlayer -
// -----------------------------------------

fn audioDataCallback(device: ?*c.ma_device, output: *c_void, input: *const c_void, frame_count: c_int32) callconv(.C) void {
    // Playback mode: Copy data to output.
    // Capture mode: Read data from input.
    // Full-Duplex mode: Both input and output will be valid.
    // Never process more frames than frame_count.
    var decoder: *c.ma_decoder = device.?.pUserData;
}
