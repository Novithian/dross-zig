// dross-zig
const Vector3 = @import("vector3.zig").Vector3;

// -----------------------------------------
//      - Color -
// -----------------------------------------

/// Color in rgba
pub const Color = struct {
    r: f32 = 0.0,
    g: f32 = 0.0,
    b: f32 = 0.0,
    a: f32 = 1.0,

    const Self = @This();

    /// Returns a color struct with the provided rgb values and a alpha of 1.0
    /// Comment: Uses 0.0-1.0 formatting
    pub fn rgb(r: f32, g: f32, b: f32) Self {
        var new_color: Color = Color{
            .r = r,
            .g = g,
            .b = b,
            .a = 1.0,
        };

        return new_color;
    }

    /// Returns a color struct with the provided rgba values 
    /// Comment: Uses 0.0-1.0 formatting
    pub fn rgba(r: f32, g: f32, b: f32, a: f32) Self {
        var new_color: Color = Color{
            .r = r,
            .g = g,
            .b = b,
            .a = a,
        };

        return new_color;
    }

    /// Returns a Vector3 filled with the Color's r, g, and b values respectively. 
    pub fn toVector3(self: Self) Vector3 {
        return Vector3.new(self.r, self.g, self.b);
    }

    /// Returns a Color struct with the values (1.0, 1.0, 1.0, 1.0).
    pub fn white() Self {
        return .{
            .r = 1.0,
            .g = 1.0,
            .b = 1.0,
            .a = 1.0,
        };
    }

    /// Returns a Color struct with the values (0.0, 0.0, 0.0, 1.0).
    pub fn black() Self {
        return .{
            .r = 0.0,
            .g = 0.0,
            .b = 0.0,
            .a = 1.0,
        };
    }

    /// Returns a Color struct with the values (1.0, 0.0, 0.0, 1.0).
    pub fn red() Self {
        return .{
            .r = 1.0,
            .g = 0.0,
            .b = 0.0,
            .a = 1.0,
        };
    }

    /// Returns a Color struct with the values (0.0, 0.0, 1.0, 1.0).
    pub fn blue() Self {
        return .{
            .r = 0.0,
            .g = 0.0,
            .b = 1.0,
            .a = 1.0,
        };
    }

    /// Returns a Color struct with the values (0.0, 1.0, 0.0, 1.0).
    pub fn green() Self {
        return .{
            .r = 0.0,
            .g = 1.0,
            .b = 0.0,
            .a = 1.0,
        };
    }

    /// Returns a Color struct with the values (0.28, 0.28, 0.28, 1.0).
    pub fn gray() Self {
        return .{
            .r = 0.28,
            .g = 0.28,
            .b = 0.28,
            .a = 1.0,
        };
    }

    /// Returns a Color struct with the values (0.12, 0.12, 0.12, 1.0).
    pub fn darkGray() Self {
        return .{
            .r = 0.12,
            .g = 0.12,
            .b = 0.12,
            .a = 1.0,
        };
    }
};
