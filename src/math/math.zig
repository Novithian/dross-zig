// Third Parties
const std = @import("std");
// dross-zig
// ------------------------------------------------

// -----------------------------------------
//      - Math -
// -----------------------------------------

pub const Math = struct {
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

    /// Returns the `value` clamped between `min` and `max`
    pub fn clamp(value: anytype, min_value: anytype, max_value: anytype) @TypeOf(value) { //type {
        const info_value = @TypeOf(value);
        const info_min = @TypeOf(min_value);
        const info_max = @TypeOf(max_value);
        if (info_value != info_min or info_value != info_max) @compileError("[Math]: The type of value, min_value, and max_value must match to use Math.clamp!");
        switch (info_value) {
            i8 => {
                var converted_value: i8 = value;
                var converted_min: i8 = min_value;
                var converted_max: i8 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            i16 => {
                var converted_value: i16 = value;
                var converted_min: i16 = min_value;
                var converted_max: i16 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            i32 => {
                var converted_value: i32 = value;
                var converted_min: i32 = min_value;
                var converted_max: i32 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            i64 => {
                var converted_value: i64 = value;
                var converted_min: i64 = min_value;
                var converted_max: i64 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            i128 => {
                var converted_value: i128 = value;
                var converted_min: i128 = min_value;
                var converted_max: i128 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            u8 => {
                var converted_value: u8 = value;
                var converted_min: u8 = min_value;
                var converted_max: u8 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            u16 => {
                var converted_value: u16 = value;
                var converted_min: u16 = min_value;
                var converted_max: u16 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            u32 => {
                var converted_value: u32 = value;
                var converted_min: u32 = min_value;
                var converted_max: u32 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            u64 => {
                var converted_value: u64 = value;
                var converted_min: u64 = min_value;
                var converted_max: u64 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            u128 => {
                var converted_value: u128 = value;
                var converted_min: u128 = min_value;
                var converted_max: u128 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            f32 => {
                var converted_value: f32 = value;
                var converted_min: f32 = min_value;
                var converted_max: f32 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            f64 => {
                var converted_value: f64 = value;
                var converted_min: f64 = min_value;
                var converted_max: f64 = max_value;
                return Math.min(Math.max(converted_value, converted_min), converted_max);
            },
            else => @compileError("[Math]: Math.clamp only supports i8, i16, i32, i64, i128, u8, u16, u32, u64, u128, f32, and f64!"),
        }
    }

    /// Returns the larger of the two values
    pub fn max(value: anytype, other: anytype) @TypeOf(value) {
        const info_value = @TypeOf(value);
        const info_other = @TypeOf(other);
        if (info_value != info_other) @compileError("[Math]: The type of value and other must match to use Math.max!");
        switch (info_value) {
            i8 => {
                var converted_value: i8 = value;
                var converted_other: i8 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            i16 => {
                var converted_value: i16 = value;
                var converted_other: i16 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            i32 => {
                var converted_value: i32 = value;
                var converted_other: i32 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            i64 => {
                var converted_value: i64 = value;
                var converted_other: i64 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            i128 => {
                var converted_value: i128 = value;
                var converted_other: i128 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            u8 => {
                var converted_value: u8 = value;
                var converted_other: u8 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            u16 => {
                var converted_value: u16 = value;
                var converted_other: u16 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            u32 => {
                var converted_value: u32 = value;
                var converted_other: u32 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            u64 => {
                var converted_value: u64 = value;
                var converted_other: u64 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            u128 => {
                var converted_value: u128 = value;
                var converted_other: u128 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            f32 => {
                var converted_value: f32 = value;
                var converted_other: f32 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            f64 => {
                var converted_value: f64 = value;
                var converted_other: f64 = other;

                return if (converted_value >= converted_other) converted_value else converted_other;
            },
            else => @compileError("[Math]: Math.max only supports i8, i16, i32, i64, i128, u8, u16, u32, u64, u128, f32, and f64!"),
        }
    }
    /// Returns the smallest of the two values
    pub fn min(value: anytype, other: anytype) @TypeOf(value) {
        const info_value = @TypeOf(value);
        const info_other = @TypeOf(other);
        if (info_value != info_other) @compileError("[Math]: The type of value and other must match to use Math.min!");
        switch (info_value) {
            i8 => {
                var converted_value: i8 = value;
                var converted_other: i8 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            i16 => {
                var converted_value: i16 = value;
                var converted_other: i16 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            i32 => {
                var converted_value: i32 = value;
                var converted_other: i32 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            i64 => {
                var converted_value: i64 = value;
                var converted_other: i64 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            i128 => {
                var converted_value: i128 = value;
                var converted_other: i128 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            u8 => {
                var converted_value: u8 = value;
                var converted_other: u8 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            u16 => {
                var converted_value: u16 = value;
                var converted_other: u16 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            u32 => {
                var converted_value: u32 = value;
                var converted_other: u32 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            u64 => {
                var converted_value: u64 = value;
                var converted_other: u64 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            u128 => {
                var converted_value: u128 = value;
                var converted_other: u128 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            f32 => {
                var converted_value: f32 = value;
                var converted_other: f32 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },
            f64 => {
                var converted_value: f64 = value;
                var converted_other: f64 = other;

                return if (converted_value <= converted_other) converted_value else converted_other;
            },

            else => @compileError("[Math]: Math.min only supports i8, i16, i32, i64, i128, u8, u16, u32, u64, u128, f32, and f64!"),
        }
    }
};

test "min and max" {
    const test_i8_one: i8 = 2;
    const test_i8_two: i8 = 5;
    std.testing.expect(Math.min(test_i8_one, test_i8_two) == 2);
    std.testing.expect(Math.min(test_i8_two, test_i8_one) == 2);
    std.testing.expect(Math.max(test_i8_one, test_i8_two) == 5);
    std.testing.expect(Math.max(test_i8_two, test_i8_one) == 5);
}

test "clamp" {
    const value: i8 = 2;
    const min_value: i8 = -1;
    const max_value: i8 = 3;
    std.testing.expect(Math.clamp(value, min_value, max_value) == @intCast(i8, 2));
    std.testing.expect(Math.clamp(value + @intCast(i8, 2), min_value, max_value) == max_value);
    std.testing.expect(Math.clamp(value - @intCast(i8, 6), min_value, max_value) == min_value);
}
