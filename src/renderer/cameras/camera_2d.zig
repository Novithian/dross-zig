// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
// dross-zig
const Application = @import("../../core/application.zig").Application;
const Matrix4 = @import("../../core/matrix4.zig").Matrix4;
const Vector3 = @import("../../core/vector3.zig").Vector3;

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
    /// The position of the camera
    position: Vector3,
    /// The target position the camera should be focusing on
    target_position: Vector3,
    /// Level of zoom
    zoom: f32 = 0.4,
    /// Determines how close something can be before getting clipped
    near: f32 = 0.0,
    /// Determines how far something can be before getting clipped
    far: f32 = 0.0,
    /// How quickly the camera will travel
    speed: f32 = 2.0,
    /// Is this camera the currently active one
    current: bool = false,

    const Self = @This();

    /// Setups the camera
    pub fn build(self: *Self) void {
        self.target_position = Vector3.new(0.0, 0.0, 0.0);
        self.zoom = 0.2;
        // self.zoom = 61.0;
        // self.zoom = 1.0;
        self.near = 0.01;
        self.far = 100.0;
        self.speed = 20.0;
        const window_size = Application.getWindowSize();
        self.position = Vector3.new(
            0.5 * self.zoom, 
            0.5 * self.zoom, 
            0.0,
        );
        // self.position = Vector3.zero();
    }

    /// Ensures to reduce the camera cound and removes the camera from the cameras list
    pub fn free(self: *Self) void {
        camera_count -= 1;
    }

    /// Sets the new target position to the desired `position`
    pub fn setTargetPosition(self: *Self, position: Vector3) void {
        self.target_position = position;
    }

    /// Sets the zoom level to the desired `zoom`
    pub fn setZoom(self: *Self, zoom: f32) void {
        // if (zoom <= 0.0) return;
        std.debug.print("Zoom: {d}\n", .{self.zoom});
        self.zoom = zoom;
    }

    /// Sets the camera speed
    pub fn setSpeed(self: *Self, speed: f32) void {
        self.speed = speed;
    }
    /// Sets the position of the camera
    pub fn setPosition(self: *Self, new_position: Vector3) void {
        self.position = self.position.copy(new_position);
    }

    /// Returns the zoom of the camera
    pub fn getZoom(self: *Self) f32 {
        return self.zoom;
    }
    /// Returns the position of the camera
    pub fn getPosition(self: *Self) Vector3 {
        return self.position;
    }

    /// Returns the speed of the camera
    pub fn getSpeed(self: *Self) f32 {
        return self.speed;
    }

    /// Returns the target position
    pub fn getTargetPosition(self: *Self) Vector3 {
        return self.target_position;
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
