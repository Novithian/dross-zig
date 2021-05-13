// Third Parties
const std = @import("std");
// dross-zig
// ------------------------------------------------

// -----------------------------------------
//      - Math Helpers -
// -----------------------------------------

/// Returns the value that is the `percentage` of the distance 
/// between `start` and `end`.
pub fn lerp(start: f32, end: f32, percentage: f32) f32 {
    return (1 - percentage) * start + end * percentage;
}