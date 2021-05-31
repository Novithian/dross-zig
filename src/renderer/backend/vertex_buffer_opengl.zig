// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");

// dross-zig
const Vertex = @import("../vertex.zig").Vertex;
// -------------------------------------------------

/// Describes how the data is used over its lifetime.
pub const BufferUsageGl = enum(c_uint) {
    /// The data is set only once, and used by the GPU at 
    /// most a few times.
    StreamDraw = c.GL_STREAM_DRAW,
    /// The data is set only once, and used many times.
    StaticDraw = c.GL_STATIC_DRAW,
    /// The data is changes frequently, and used many times.
    DynamicDraw = c.GL_DYNAMIC_DRAW,
};

// -----------------------------------------
//      - VertexBufferGl -
// -----------------------------------------

/// Container for storing a large number of vertices in the GPU's memory.
pub const VertexBufferGl = struct {
    /// OpenGL generated ID
    handle: c_uint,

    const Self = @This();

    /// Allocates and builds a new VertexBufferGl
    /// Comments: The caller will own the allocated memory.
    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var self = try allocator.create(VertexBufferGl);

        c.glGenBuffers(1, &self.handle);

        return self;
    }

    /// Cleans up and de-allocates the Vertex Buffer
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        c.glDeleteBuffers(1, &self.handle);
        allocator.destroy(self);
    }

    /// Returns the id OpenGL-generated id
    pub fn id(self: *Self) c_uint {
        return self.handle;
    }

    /// Binds the Vertex Buffer to the current buffer target.
    pub fn bind(self: *Self) void {
        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.handle);
    }

    /// Allocates memory and stores data within the currently bound buffer object.
    pub fn data(self: Self, vertices: []const f32, usage: BufferUsageGl) void {
        const vertices_ptr = @ptrCast(*const c_void, vertices.ptr);
        const vertices_size = @intCast(c_longlong, @sizeOf(f32) * vertices.len);

        c.glBufferData(c.GL_ARRAY_BUFFER, vertices_size, vertices_ptr, @enumToInt(usage));
    }

    /// Allocates memory and stores data within the currently bound buffer object.
    pub fn dataV(self: Self, vertices: []Vertex, usage: BufferUsageGl) void {
        const vertices_ptr = @ptrCast(*const c_void, vertices.ptr);
        const vertices_size = @intCast(c_longlong, @sizeOf(Vertex) * vertices.len);

        c.glBufferData(c.GL_ARRAY_BUFFER, vertices_size, vertices_ptr, @enumToInt(usage));
    }
    /// Allocates memory within the the currently bound buffer object.
    /// `length` is the amount of floats to reserve.
    pub fn dataless(self: Self, length: f32, usage: BufferUsageGl) void {
        const size = @floatToInt(c_longlong, @sizeOf(f32) * length);

        c.glBufferData(c.GL_ARRAY_BUFFER, size, null, @enumToInt(usage));
    }

    /// Overwrites previously allocated data within the currently bound buffer object.
    pub fn subdata(self: Self, vertices: []const f32) void {
        const size = @intCast(c_longlong, @sizeOf(f32) * vertices.len);
        const ptr = @ptrCast(*const c_void, vertices.ptr);
        c.glBufferSubData(c.GL_ARRAY_BUFFER, 0, size, ptr);
    }

    /// Overwrites previously allocated data within the currently bound buffer object.
    pub fn subdataV(self: Self, vertices: []Vertex) void {
        const size = @intCast(c_longlong, @sizeOf(Vertex) * vertices.len);
        const ptr = @ptrCast(*const c_void, vertices.ptr);
        c.glBufferSubData(c.GL_ARRAY_BUFFER, 0, size, ptr);
    }

    /// Clears out the currently bound Vertex Buffer
    pub fn clearBoundVertexBuffer() void {
        c.glBindBuffer(c.GL_ARRAY_BUFFER, 0);
    }
};
