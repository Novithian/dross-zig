// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");

// dross-zig
// -----------------------------------------------

// -----------------------------------------
//      - Vertex Array Object -
// -----------------------------------------

/// Stores the Vertex Attributes
pub const VertexArrayGl = struct {
    /// OpenGL generated ID
    handle: c_uint,

    const Self = @This();

    /// Allocates and sets up a VertexArrayGl instance
    /// Comments: The caller will own the allocated memory.
    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var self = try allocator.create(VertexArrayGl);

        c.glGenVertexArrays(1, &self.handle);

        return self;
    }

    /// Cleans up and de-allocates the VertexArrayGl instance 
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        c.glDeleteVertexArrays(1, &self.handle);

        allocator.destroy(self);
    }

    /// Returns the id OpenGL-generated id
    pub fn id(self: *Self) c_uint {
        return self.handle;
    }

    /// Binds the Vertex Array
    pub fn bind(self: *Self) void {
        c.glBindVertexArray(self.handle);
    }

    /// Clears out the currently bound Vertex Array
    pub fn clearBoundVertexArray() void {
        c.glBindVertexArray(0);
    }
};
