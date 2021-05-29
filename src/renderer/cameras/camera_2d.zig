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
    internal_position: Vector3,
    /// The target position the camera should be focusing on
    internal_target_position: Vector3,
    /// Level of zoom
    internal_zoom: f32 = 0.4,
    /// Determines how close something can be before getting clipped
    internal_near: f32 = 0.0,
    /// Determines how far something can be before getting clipped
    internal_far: f32 = 0.0,
    /// How quickly the camera will travel
    internal_speed: f32 = 2.0,
    /// Is this camera the currently active one
    current: bool = false,

    const Self = @This();

    /// Allocates and setup a Camera2D instance
    /// Comments: The caller will own the camera, which
    /// means they will be responsible for freeing.
    pub fn new(allocator: *std.mem.Allocator) !*Camera2D {
        var self = try allocator.create(Camera2d);

        self.internal_target_position = Vector3.new(0.0, 0.0, 0.0);
        self.internal_zoom = 4.0;
        self.internal_near = 0.01;
        self.internal_far = 100.0;
        self.internal_speed = 20.0;

        //const window_size = Application.windowSize();
        //self.position = Vector3.new(
        //    0.5 * self.zoom,
        //    0.5 * self.zoom,
        //    0.0,
        //);
        // self.position = Vector3.zero();

        if (camera_count == 0) {
            camera_count += 1;
            // TODO(devon): We'll have to check if this already exists at some point
            self.*.id = camera_count;
            self.*.current = true;
            current_camera = self;
        } else {
            camera_count += 1;
        }

        return self;
    }

    /// Ensures to reduce the camera cound and removes the camera from the cameras list
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        camera_count -= 1;
        allocator.destroy(self);
    }

    /// Sets the new target position to the desired `position`
    pub fn setTargetPosition(self: *Self, position: Vector3) void {
        self.internal_target_position = position;
    }

    /// Sets the zoom level to the desired `zoom`
    pub fn setZoom(self: *Self, zoom: f32) void {
        self.internal_zoom = zoom;
    }

    /// Sets the camera speed
    pub fn setSpeed(self: *Self, speed: f32) void {
        self.internal_speed = speed;
    }
    /// Sets the position of the camera
    pub fn setPosition(self: *Self, new_position: Vector3) void {
        self.internal_position = self.position.copy(new_position);
    }

    /// Returns the zoom of the camera
    pub fn zoom(self: *Self) f32 {
        return self.internal_zoom;
    }
    /// Returns the position of the camera
    pub fn position(self: *Self) Vector3 {
        return self.internal_position;
    }

    /// Returns the speed of the camera
    pub fn speed(self: *Self) f32 {
        return self.internal_speed;
    }

    /// Returns the target position
    pub fn targetPosition(self: *Self) Vector3 {
        return self.internal_target_position;
    }
};

/// Returns the current camera if one is set, otherwise it will return null
pub fn currentCamera() ?*Camera2d {
    if (current_camera != undefined) return current_camera;
    return null;
}
