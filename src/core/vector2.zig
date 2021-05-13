// Third Parties
const std = @import("std");
const za = @import("zalgebra");
const Vec2 = za.vec2;
// dross-zig
// -----------------------------------------

// -----------------------------------------
//      - Vector2 -
// -----------------------------------------
pub const Vector2 = struct {
    data: Vec2,

    const Self = @This();

    /// Builds and returns a new Vector2 with the compoents
    /// set to their respective passed values.
    pub fn new(x_value: f32, y_value: f32) Self {
        return Self{
            .data = Vec2.new(x_value, y_value),
        };
    }

    /// Returns the value of the x component
    pub fn getX(self: Self) f32 {
        return self.data.x;
    }

    /// Returns the value of the y component
    pub fn getY(self: Self) f32 {
        return self.data.y;
    }

    /// Builds and returns a Vector2 with all components
    /// set to `value`.
    pub fn setAll(value: f32) Self {
        return Self{
            .data = Vec2.set(value),
        };
    }

    /// Shorthand for a zeroed out Vector2
    pub fn zero() Self {
        return Self{
            .data = Vec2.zero(),
        };
    }

    /// Shorthand for (0.0, 1.0)
    pub fn up() Self {
        return Self{
            .data = Vec2.up(),
        };
    }

    /// Shorthand for (1.0, 0.0)
    pub fn right() Self {
        return Self{
            .data = Vec2.new(1.0, 0.0),
        };
    }

    /// Transform vector to an array
    pub fn toArray(self: Self) [2]f32 {
        return self.data.to_array();
    }

    /// Returns the angle (in degrees) between two vectors.
    pub fn getAngle(lhs: Self, rhs: Self) f32 {
        return lhs.data.get_angle(rhs.data);
    }

    /// Returns the length (magnitude) of the calling vector |a|.
    pub fn length(self: Self) f32 {
        return self.data.length();
    }

    /// Returns a normalized copy of the calling vector.
    pub fn normalize(self: Self) Self {
        return Self{
            .data = self.data.norm(),
        };
    }

    /// Returns whether two vectors are equal or not
    pub fn isEqual(lhs: Self, rhs: Self) bool {
        return lsh.data.is_eq(rhs.data);
    }

    /// Subtraction between two vectors.
    pub fn subtract(lhs: Self, rhs: Self) Self {
        return Self{
            .data = Vec2.sub(lhs.data, rhs.data),
        };
    }

    /// Addition between two vectors.
    pub fn add(lhs: Self, rhs: Self) Self {
        return Self{
            .data = Vec2.add(lhs.data, rhs.data),
        };
    }

    /// Returns a new Vector2 multiplied by a scalar value
    pub fn scale(self: Self, scalar: f32) Self {
        return Self{
            .data = self.data.scale(scalar),
        };
    }

    /// Returns the dot product between two given vectors.
    pub fn dot(lhs: Self, rhs: Self) f32 {
        return lhs.data.dot(rhs.data);
    }

    /// Returns a linear interpolated Vector3 of the given vectors.
    /// t: [0.0 - 1.0] - How much should lhs move towards rhs
    /// Formula for a single value:
    /// start * (1 - t) + end * t
    pub fn lerp(lhs: Self, rhs: Self, t: f32) Self {
        return Self{
            .data = lhs.data.lerp(rhs.data, t),
        };
    }
};
