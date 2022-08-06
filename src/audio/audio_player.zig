// Third-Party
const std = @import("std");
const c = @import("../c_global.zig").c_imp;
// Dross-zig
const ad = @import("audio_device.zig");
pub const AudioDevice = ad.AudioDevice;
pub const AudioDeviceType = ad.AudioDeviceType;
// ------------------------------------

// -----------------------------------------
//      - AudioPlayer -
// -----------------------------------------
///
pub const AudioPlayer = struct {
    device: ?*AudioDevice = undefined,

    const Self = @This();

    pub fn new(allocator: std.mem.Allocator) !*Self {
        var self = try allocator.create(AudioPlayer);

        self.device = try AudioDevice.new(allocator);

        return self;
    }

    pub fn free(allocator: std.mem.Allocator, self: *Self) void {
        AudioDevice.free(allocator, self.device.?);
        allocator.destroy(self);
    }
};

///
fn audioDataCallback(device: ?*c.ma_device, output: *c_void, input: *const c_void, frame_count: c_int32) callconv(.C) void {
    // Playback mode: Copy data to output.
    // Capture mode: Read data from input.
    // Full-Duplex mode: Both input and output will be valid.
    // Never process more frames than frame_count.
    // var decoder: *c.ma_decoder = device.?.pUserData;
    _ = device;

    _ = output;
    _ = input;
    _ = frame_count;
}
