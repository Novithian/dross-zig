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
    /// Horizontal texture coordinate
    u: f32,
    /// Vertical texture coordinate
    v: f32,
};
