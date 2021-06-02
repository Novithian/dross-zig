// Third Parties
const std = @import("std");
const za = @import("zalgebra");
const Vec2 = za.vec2;
const Vec3 = za.vec3;
const Vec4 = za.vec4;
// dross-zig
const Vector2 = @import("vector2.zig").Vector2;
const Vector3 = @import("vector3.zig").Vector3;

// -----------------------------------------
//      - Vector4 -
// -----------------------------------------
pub const Vector4 = struct {
    data: Vec4,

    const Self = @This();

    /// Builds and returns a new Vector4 with the compoents
    /// set to their respective passed values.
    pub fn new(x_value: f32, y_value: f32, z_value: f32, w_value: f32) Self {
        return Self{
            .data = Vec4.new(x_value, y_value, z_value, w_value),
        };
    }

    /// Create a Vector4 from a given Vector2 and a z and w value
    pub fn fromVector2(xy: Vector2, desired_z: f32, desired_w: f32) Self {
        return Self{
            .data = Vec4.new(xy.x(), xy.y(), desired_z, desired_w),
        };
    }

    /// Create a Vector4 from a given Vector3 and a w value
    pub fn fromVector3(xyz: Vector3, desired_w: f32) Self {
        return Self{
            .data = Vec4.new(xyz.x(), xyz.y(), xyz.z(), desired_w),
        };
    }

    /// Returns the value of the x component
    pub fn x(self: Self) f32 {
        return self.data.x;
    }

    /// Returns the value of the y component
    pub fn y(self: Self) f32 {
        return self.data.y;
    }

    /// Returns the value of the z component
    pub fn z(self: Self) f32 {
        return self.data.z;
    }

    /// Returns the value of the w component
    pub fn w(self: Self) f32 {
        return self.data.w;
    }

    /// Builds and returns a Vector4 with all components
    /// set to `value`.
    pub fn setAll(value: f32) Self {
        return Self{
            .data = Vec4.set(value),
        };
    }

    /// Copies the values of the given Vector
    pub fn copy(self: Self, other: Self) Self {
        return .{
            .data = Vec4.new(other.data.x, other.data.y, other.data.z, other.data.w),
        };
    }

    /// Shorthand for a zeroed out Vector4
    pub fn zero() Self {
        return Self{
            .data = Vec4.zero(),
        };
    }

    /// Transform vector to an array
    pub fn toArray(self: Self) [4]f32 {
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
        return lhs.data.is_eq(rhs.data);
    }

    /// Subtraction between two vectors.
    pub fn subtract(lhs: Self, rhs: Self) Self {
        return Self{
            .data = Vec4.sub(lhs.data, rhs.data),
        };
    }

    /// Addition between two vectors.
    pub fn add(lhs: Self, rhs: Self) Self {
        return Self{
            .data = Vec4.add(lhs.data, rhs.data),
        };
    }

    /// Returns a new Vector4 multiplied by a scalar value
    pub fn scale(self: Self, scalar: f32) Self {
        return Self{
            .data = self.data.scale(scalar),
        };
    }

    /// Returns the cross product of the given vectors.
    pub fn cross(lhs: Self, rhs: Self) Self {
        return Self{
            .data = lhs.data.cross(rhs.data),
        };
    }

    /// Returns the dot product between two given vectors.
    pub fn dot(lhs: Self, rhs: Self) f32 {
        return lhs.data.dot(rhs.data);
    }

    /// Returns a linear interpolated Vector4 of the given vectors.
    /// t: [0.0 - 1.0] - How much should lhs move towards rhs
    /// Formula for a single value:
    /// start * (1 - t) + end * t
    pub fn lerp(lhs: Self, rhs: Self, t: f32) Self {
        return Self{
            .data = lhs.data.lerp(rhs.data, t),
        };
    }

    /// Returns a random Vector4 with a minimum range of `min` and
    /// a maximum range of `max`, inclusively. If 
    pub fn random(max: f32) !Self {
        var prng = std.rand.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.os.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });

        const rand = &prng.random;

        return Self{
            .data = Vec4.new(
                rand.float(f32) * max,
                rand.float(f32) * max,
                rand.float(f32) * max,
                rand.float(f32) * max,
            ),
        };
    }
};