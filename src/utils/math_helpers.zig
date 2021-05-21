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

/// Returns the absolute value of `value`
pub fn abs(value: f32) f32 {
    if (value < 0.0) return value * -1.0;
    return value;
}
