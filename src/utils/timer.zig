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
    start_time: f64 = 0,
    is_running: bool = false,
    const Self = @This();

    /// Allocates and builds a Timer
    /// Comments: The caller will own the memory
    pub fn new(allocator: *std.mem.Allocator, label: []const u8) *Self {
        var timer = allocator.create(Timer) catch |err| {
            std.debug.print("[Timer]: Error occurred when creating a timer! {s}\n", .{err});
            @panic("[Timer]: Error occurred creating a timer!\n");
        };
        timer.label = label;
        timer.start_time = -1.0;
        timer.is_running = false;
        return timer;
    }

    /// Frees up the timer
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        if (self.is_running) {
            _ = self.stop();
        }

        allocator.destroy(self);
    }

    /// Starts the timer
    pub fn start(self: *Self) void {
        self.is_running = true;
        self.start_time = @intToFloat(f64, time.nanoTimestamp());
    }

    /// Stops the timer
    pub fn stop(self: *Self) f64 {
        if (!self.is_running) return -1.0;
        self.is_running = false;
        const end_time = @intToFloat(f64, time.nanoTimestamp());
        const duration = (end_time - self.start_time) / @intToFloat(f64, std.time.ns_per_ms);

        std.debug.print("[Timer][{s}]: {d:5} ms\n", .{ self.label, duration });

        return duration;
    }

    /// Reset the timer
    pub fn reset(self: *Self) void {
        self.start_time = @intToFloat(f64, timer.nanoTimestamp());
    }
};
