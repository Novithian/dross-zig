// Third Parties
const std = @import("std");
const c = @import("../../c_global.zig").c_imp;
// dross-zig
const Vector2 = @import("../../core/vector2.zig").Vector2;
const tx = @import("../texture.zig");
const Texture = tx.Texture;
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - FrameStatistics -
// -----------------------------------------
var stats: ?*FrameStatistics = undefined;

pub const FrameStatistics = struct {
    /// The total time taken to process a frame (in ms)
    frame_time: f64 = -1.0,
    /// The total time taken to draw (in ms)
    draw_time: f64 = -1.0,
    /// The total time the user-defined update function takes (in ms)
    update_time: f64 = -1.0,
    /// The number of quads being renderered
    quad_count: i64 = -1.0,
    /// The number of draw calls per frame
    draw_calls: i64 = -1.0,

    const Self = @This();

    /// Creates a new instance of FrameStatistics.
    /// Comments: The memory allocated will be engine-owned.
    pub fn new(allocator: *std.mem.Allocator) !void {
        stats = try allocator.create(FrameStatistics);

        stats.?.frame_time = -1.0;
        stats.?.draw_time = -1.0;
        stats.?.update_time = -1.0;
    }

    /// Cleans up and de-allocates if a FrameStatistics instance exists.
    pub fn free(allocator: *std.mem.Allocator) void {
        allocator.destroy(stats.?);
    }

    /// Sets the frame time 
    pub fn setFrameTime(new_time: f64) void {
        stats.?.frame_time = new_time;
    }

    /// Returns the currently stored frame time
    pub fn frameTime() f64 {
        return stats.?.frame_time;
    }

    /// Sets the draw time 
    pub fn setDrawTime(new_time: f64) void {
        stats.?.draw_time = new_time;
    }

    /// Returns the currently stored draw time
    pub fn drawTime() f64 {
        return stats.?.draw_time;
    }

    /// Sets the update time 
    pub fn setUpdateTime(new_time: f64) void {
        stats.?.update_time = new_time;
    }

    /// Returns the currently stored update time
    pub fn updateTime() f64 {
        return stats.?.update_time;
    }

    /// Returns the total numbert of draw calls recorded for the frame
    pub fn drawCalls() i64 {
        return stats.?.draw_calls;
    }

    /// Returns the total of quads being renderered
    pub fn quadCount() i64 {
        return stats.?.quad_count;
    }

    /// Returns the total vertex count being drawn 
    pub fn vertexCount() i64 {
        return stats.?.quad_count * 4;
    }

    /// Returns the total index count being drawn 
    pub fn indexCount() i64 {
        return stats.?.quad_count * 6;
    }

    /// Resets the frame statistics: 
    /// `quad_count`
    /// `draw_calls`
    pub fn reset() void {
        stats.?.quad_count = 0;
        stats.?.draw_calls = 0;
    }

    /// Increments the quad count.
    pub fn incrementQuadCount() void {
        stats.?.quad_count += 1;
    }

    /// Increments the draw call count.
    pub fn incrementDrawCall() void {
        stats.?.draw_calls += 1;
    }

    /// Debug prints all of the stats
    pub fn display() void {
        std.debug.print("[Timer]Frame: {d:5} ms\n", .{stats.?.frame_time});
        //std.debug.print("[Timer]User Update: {d:5} ms\n", .{stats.?.update_time});
        //std.debug.print("[Timer]Draw: {d:5} ms\n", .{stats.?.draw_time});
        //std.debug.print("[Timer]Draw Calls: {}\n", .{stats.?.draw_calls});
        //std.debug.print("[Timer]Quad Count: {}\n", .{stats.?.quad_count});
    }
};
