// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");

// dross-zig
const vbgl = @import("vertex_buffer_opengl.zig");
const VertexBufferGl = vbgl.VertexBufferGl;
const BufferUsageGl = vbgl.BufferUsageGl;
// --------------------------------------------------

// -----------------------------------------
//      - IndexBufferGl -
// -----------------------------------------

/// Stores indices that will be used to decide what vertices to draw.
pub const IndexBufferGl = struct {
    /// OpenGL generated ID
    handle: c_uint,
    /// Number of indices
    index_count: c_uint,

    const Self = @This();

    /// Allocates and sets up a new IndexBufferGl instance.
    /// Comments: The caller will own the allocated data.
    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var self = try allocator.create(IndexBufferGl);

        c.glGenBuffers(1, &self.handle);

        return self;
    }

    /// Cleans up and de-allocates the Index Buffer
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        c.glDeleteBuffers(1, &self.handle);

        allocator.destroy(self);
    }

    /// Returns the id OpenGL-generated id
    pub fn id(self: *Self) c_uint {
        return self.handle;
    }

    /// Returns the count of the Index Buffer
    pub fn count(self: *Self) c_int {
        return self.index_count;
    }

    /// Binds the Index Buffer
    pub fn bind(self: *Self) void {
        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, self.handle);
    }

    /// Allocates memory and stores data within the the currently bound buffer object.
    pub fn data(self: *Self, indices: []const c_uint, usage: BufferUsageGl) void {
        self.index_count = @intCast(c_uint, indices.len);
        const indices_ptr = @ptrCast(*const c_void, indices.ptr);
        const indices_size = @intCast(c_longlong, @sizeOf(c_uint) * indices.len);

        c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, indices_size, indices_ptr, @enumToInt(usage));
    }
};
