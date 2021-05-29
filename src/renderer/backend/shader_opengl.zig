// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");

// dross-zig
const OpenGlError = @import("renderer_opengl.zig").OpenGlError;
const FileLoader = @import("../../utils/file_loader.zig");
// -----------------------------------------

// -----------------------------------------
//      - ShaderTypeGl -
// -----------------------------------------

//TODO(devon): Move to Shader.zig eventually
/// Describes what type of shader 
pub const ShaderTypeGl = enum(c_uint) {
    Vertex = c.GL_VERTEX_SHADER,
    Fragment = c.GL_FRAGMENT_SHADER,
    Geometry = c.GL_GEOMETRY_SHADER,
};

// -----------------------------------------
//      - ShaderGl -
// -----------------------------------------

/// Container that processes and compiles a sources GLSL file
pub const ShaderGl = struct {
    /// OpenGL generated ID
    handle: c_uint,
    shader_type: ShaderTypeGl,

    const Self = @This();

    /// Allocates and builds the shader of the requested shader type
    pub fn new(allocator: *std.mem.Allocator, shader_type: ShaderTypeGl) !*Self {
        var self = try allocator.create(ShaderGl);

        self.handle = c.glCreateShader(@enumToInt(shader_type));
        self.shader_type = shader_type;

        return self;
    }

    /// Cleans up and de-allocates the Shader instance 
    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        c.glDeleteShader(self.handle);

        allocator.destroy(self);
    }

    /// Returns the OpenGL-generated shader id
    pub fn id(self: *Self) c_uint {
        return self.handle;
    }

    /// Sources a given GLSL shader file
    pub fn source(self: *Self, path: [:0]const u8) !void {
        const source_slice = FileLoader.loadFile(path) catch |err| {
            std.debug.print("[Shader]: Failed to load shader ({s})! {}\n", .{ path, err });
            return err;
        };

        const source_size = source_slice.?.len;

        c.glShaderSource(self.handle, 1, &source_slice.?.ptr, @ptrCast(*const c_int, &source_size));
    }

    /// Compiles the previously sources GLSL shader file, and checks for any compilation errors.
    pub fn compile(self: *Self) !void {
        var no_errors: c_int = undefined;
        var compilation_log: [512]u8 = undefined;

        c.glCompileShader(self.handle);

        c.glGetShaderiv(self.handle, c.GL_COMPILE_STATUS, &no_errors);

        // If the compilation failed, log the message
        if (no_errors == 0) {
            c.glGetShaderInfoLog(self.handle, 512, null, &compilation_log);
            std.log.err("[Renderer][OpenGL]: Failed to compile {s} shader: \n{s}", .{ self.shader_type, compilation_log });
            return OpenGlError.ShaderCompilationFailure;
        }
    }
};

// ------------------------------------------
//      - Tests -
// ------------------------------------------
test "Read Shader Test" {
    const file = try std.fs.cwd().openFile(
        "src/renderer/shaders/default_shader.vs",
        .{},
    );

    defer file.close();

    var buffer: [4096]u8 = undefined;
    try file.seekTo(0);
    const bytes_read = try file.readAll(&buffer);
    const slice = buffer[0..bytes_read];
    std.debug.print("{s}\n", .{slice});
}
