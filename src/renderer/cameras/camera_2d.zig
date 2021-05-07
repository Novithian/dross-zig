// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
const za = @import("zalgebra");
const Vec3 = za.vec3;
const Mat4 = za.mat4;
// dross-zig
const app = @import("../../core/application.zig");

// How many cameras are instantiated in the scene
var camera_count: u8 = 0;
/// The currently active camera
var current_camera: *Camera2d = undefined;

/// ErrorSet for possible camera related errors
pub const CameraError = error{
    /// Requested camera could not be found
    CameraNotFound,
};

// -----------------------------------------
//      - Camera2D -
// -----------------------------------------

// All Cameras will be accounted for by the framework.
// Instance will be created via the buildCamera2d, and
// freed from freeAllCamera2d and freeCamera2d(id).
// Each camera will get given a unique ID, and will be
// added and removed from a list of cameras in the scene.
// There can only get a single "active" camera, which
// is what will be rendered to the display.

/// Orthographic camera implementation
pub const Camera2d = struct {
    /// Unique Camera ID
    id: u16,
    /// The target position the camera should be focusing on
    target_position: Vec3,
    /// Level of zoom
    zoom: f32 = 1.0,
    /// Determines how close something can be before getting clipped
    near: f32 = 0.0,
    /// Determines how far something can be before getting clipped
    far: f32 = 0.0,
    /// Is this camera the currently active one
    current: bool = false,

    const Self = @This();

    /// Setups the camera
    pub fn build(self: *Self) void {
        self.target_position = Vec3.new(0.0, 0.0, 0.0);
        self.zoom = 1.0;
        self.near = 0.01;
        self.far = 100.0;
    }

    /// Ensures to reduce the camera cound and removes the camera from the cameras list
    pub fn free(self: *Self) void {
        camera_count -= 1;
    }

    /// Returns the projection matrix
    pub fn projectionMatrix(self: *Self) Mat4 {
        // const left = self.target_position.x - app.window_size.x / 2.0;
        // const right = self.target_position.x + app.window_size.x / 2.0;
        // const top = self.target_position.y - app.window_size.y / 2.0;
        // const bottom = self.target_position.y + app.window_size.y / 2.0;
        const left = self.target_position.x;
        const right = self.target_position.x + app.window_size.x;
        const top = self.target_position.y;
        const bottom = self.target_position.y + app.window_size.y;

        var orthographic_matrix: Mat4 = Mat4.orthographic(left, right, bottom, top, self.near, self.far);
        var zoom_matrix: Mat4 = Mat4.from_scale(Vec3.new(self.zoom, self.zoom, self.zoom));

        return Mat4.mult(orthographic_matrix, zoom_matrix);
    }

    /// Sets the new target position to the desired `position`
    pub fn setTargetPosition(self: *Self, position: Vec3) void {
        self.target_position = position;
    }

    /// Sets the zoom level to the desired `zoom`
    pub fn setZoom(self: *Self, zoom: f32) void {
        self.zoom = zoom;
    }
};

/// Returns the current camera if one is set, otherwise it will return null
pub fn getCurrentCamera() ?*Camera2d {
    if (current_camera != undefined) return current_camera;
    return null;
}

/// Allocates and setup a Camera2D
/// Comments: The framework is the owner of the Camera.
pub fn buildCamera2d(allocator: *std.mem.Allocator) anyerror!void {
    var camera = try allocator.create(Camera2d);

    camera.build();

    if (camera_count == 0) {
        camera_count += 1;
        // TODO(devon): We'll have to check if this already exists at some point
        camera.*.id = camera_count;
        camera.*.current = true;
        current_camera = camera;
    }
    // return camera;
}

/// Frees all known Cameras2d instances
pub fn freeAllCamera2d(allocator: *std.mem.Allocator) void {
    if (current_camera != undefined) {
        current_camera.free();
        allocator.destroy(current_camera);
    }
}
