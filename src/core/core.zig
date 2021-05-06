// Contains common core types found in dross-zig

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
};

