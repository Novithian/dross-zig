// Third Parties
const std = @import("std");
const za = @import("zalgebra");
const Vec4 = za.vec4;
const Mat4 = za.mat4;
// dross-zig
const Vector3 = @import("vector3.zig").Vector3;

// -----------------------------------------
//      - Matrix4 -
// -----------------------------------------

//[1, 0, 0, tx]
//[0, 1, 0, ty]
//[0, 0, 1, tz]
//[0, 0, 0,  1]
// Translation Matrix

//[sx, 0,  0, 0]
//[0, sy,  0, 0]
//[0,  0, sz, 0]
//[0,  0,  0, 1]
// Scaling Matrix

/// 
pub const Matrix4 = struct {
    data: Mat4 = undefined,

    const Self = @This();

    /// Creates a 4x4 matrix with all 0s , expect 1s that are along the diagonal
    pub fn identity() Self {
        return .{
            .data = Mat4.identity(),
        };
    }

    /// Construct a new 4x4 matrix from the given slice
    pub fn fromSlice(data: *const [16]f32) Self {
        return = .{
            .data = Mat4.from_slice(data),
        };
    }

    /// Evaluates whether the two matrices are equal to one another.
    pub fn isEqual(left: Self, right: Self) bool {
        return Mat4.is_eq(left.data, right.data);
    }

    /// Multiplies the matrix by a Vector4(f32) and returns the resulting Vector4(f32)
    pub fn multiplyVec4(self: Self, v: Vec4) Vec4 {
        return self.data.mult_by_vec4(v);
    }

    /// Builds a 4x4 translation matrix by multiplying an
    /// identity matrix and the given translation vector.
    pub fn fromTranslate(axis: Vector3) Self {
        return .{
            .data = Mat4.from_translate(axis.data),
        };
    }

    /// Translates the matrix by the given axis vector.
    pub fn translate(self: Self, axis: Vector3) Self {
        return .{
            .data = self.data.translate(axis.data),
        };
    }

    /// Returns the translation vector from the transform matrix
    pub fn translation(self: Self) Vector3 {
        return Vector3{
            .data = self.data.extract_translation(),
        };
    }

    /// Builds a new 4x4 matrix from the given axis and angle (in degrees).
    pub fn fromRotation(angle_deg: f32, axis: Vector3) Self {
        return = .{
            .data = Mat4.from_rotation(angle_deg, axis.data),
        };
    }

    /// Rotates the matrix by the given angle (in degrees) along the given axis.
    pub fn rotate(self: Self, angle_deg: f32, axis: Vector3) Self {
        return .{
            .data = self.data.rotate(angle_deg, axis.data),
        };
    }

    /// Builds a rotation matrix from euler angles (X * Y * Z).
    pub fn fromEulerAngle(euler_angle: Vector3) Self {
        return = .{
            .data = Mat4.from_euler_angle(euler_angle),
        };
    }

    /// Returns an Orthogonal normalized matrix
    pub fn orthogonalNormalized(self: Self) Self {
        return .{
            .data = self.data.ortho_normalize(),
        };
    }

    /// Returns the rotation from the matrix as Euler angles (in degrees).
    pub fn rotation(self: Self) Vector3 {
        return Vector3{
            .data = self.data.extract_rotation(),
        };
    }

    /// Builds a new matrix 4x4 from the given scaling vector.
    pub fn fromScale(axis: Vector3) Self {
        return .{
            .data = Mat4.from_scale(axis.data),
        };
    }

    /// Scales the matrix by the given scaling axis
    pub fn scale(self: Self, axis: Vector3) Self {
        return .{
            .data = self.data.scale(axis.data),
        };
    }

    /// Returns the scale from the transform matrix as a Vector3.
    pub fn scaling(self: Self) Vector3 {
        return Vector3{
            .data = self.data.extract_scale(),
        };
    }

    /// Builds a perspective 4x4 matrix
    pub fn perspective(fov_deg: f32, aspect_ratio: f32, z_near: f32, z_far: f32) Self {
        return .{
            .data = Mat4.perspective(fov_deg, aspect_ratio, z_near, z_far),
        };
    }

    /// Build a orthographic 4x4 matrix
    pub fn orthographic(left: f32, right: f32, bottom: f32, top: f32, z_near: f32, z_far: f32) Self {
        return .{
            .data = Mat4.orthographic(left, right, bottom, top, z_near, z_far),
        };
    }

    /// Performs a right-handed look at
    pub fn lookAt(eye: Vector3, target: Vector3, up: Vector3) Self {
        return .{
            .data = Mat4.look_at(eye.data, target.data, up.data),
        };
    }

    /// Builds a new Matrix 4x4 via Matrix multiplication
    pub fn mult(left: Self, right: Self) Self {
        return .{
            .data = Mat4.mult(left.data, right.data),
        };
    }

    /// Builds an inverse Matrix 4x4 from the given matrix
    pub fn inverse(self: Self) Self {
        return .{
            .data = self.data.inv(),
        };
    }
};
