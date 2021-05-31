// Third Parties
const std = @import("std");
const c = @import("../../c_global.zig").c_imp;
// dross-zig
// -----------------------------------------------------------------------------

// -----------------------------------------
//      - Vertex -
// -----------------------------------------

///
pub const Vertex = packed struct {
    /// Position of the vertex
    x: f32,
    y: f32,
    z: f32,
    /// Vertex Color
    r: f32,
    g: f32,
    b: f32,
    a: f32,
    /// Texture coordinate
    u: f32,
    v: f32,
};
