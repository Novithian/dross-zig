// Third Parties
const std = @import("std");
const time = std.time;
// dross-zig
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - Timer -
// -----------------------------------------
pub const Timer = struct {
    label: []const u8 = undefined,
    start_time: i128 = 0,
    is_running: bool = false,
    const Self = @This();

    /// Allocates and builds a Timer
    /// Comments: The caller will own the memory
    pub fn build(allocator: *std.mem.Allocator, label: []const u8) !*Self {
        var timer = try allocator.create(Timer);
        timer.label = label;
        timer.start_time = 0;
        timer.is_running = false;
        return timer;
    }

    /// Frees up the timer
    pub fn free(self: *Self) void {
        if (self.is_running) {
            self.stop();
        }
    }

    /// Starts the timer
    pub fn start(self: *Self) void {
        self.is_running = true;
        self.start_time = time.nanoTimestamp();
    }

    /// Stops the timer
    pub fn stop(self: *Self) void {
        self.is_running = false;
        const end_time = time.nanoTimestamp();
        const duration = @intCast(u128, (end_time - self.start_time)) / std.time.ns_per_ms;

        //std.debug.print("[Timer][{s}]: Duration {} ms\n", .{ self.label, duration });
        std.debug.print("[Timer][{s}]: Duration {} ms\n", .{ self.label, duration });
    }
};
