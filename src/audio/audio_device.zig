// Third-Party
const std = @import("std");
const c = @import("../c_global.zig").c_imp;
// Dross-zig
// ------------------------------------

// -----------------------------------------
//      - AudioDeviceType -
// -----------------------------------------
///
pub const AudioDeviceType = enum(u8) {
    Playback = c.ma_device_type_playback,
    Capture = c.ma_device_type_capture,
    Duplex = c.ma_device_type_duplex,
    Loopback = c.ma_device_type_loopback,
};

// -----------------------------------------
//      - AudioDeviceConfig -
// -----------------------------------------
///
pub const AudioDeviceConfig = struct {
    const Self = @This();

    pub fn new(allocator: std.mem.Allocator) !*Self {
        var self = try allocator.create(AudioDeviceConfig);

        return self;
    }

    pub fn free(allocator:std.mem.Allocator, self: *Self) void {
        allocator.destroy(self);
    }
};

// -----------------------------------------
//      - AudioDevice -
// -----------------------------------------
///
pub const AudioDevice = struct {
    config: ?*AudioDeviceConfig = undefined,

    const Self = @This();

    pub fn new(allocator: std.mem.Allocator) !*Self {
        var self = try allocator.create(AudioDevice);

        self.config = try AudioDeviceConfig.new(allocator);

        return self;
    }

    pub fn free(allocator: std.mem.Allocator, self: *Self) void {
        AudioDeviceConfig.free(allocator, self.config.?);
        allocator.destroy(self);
    }
};
