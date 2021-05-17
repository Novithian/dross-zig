// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
// dross-zig
const glfb = @import("backend/framebuffer_opengl.zig");
const FramebufferGl = glfb.FramebufferOpenGl;
const texture = @import("texture.zig");
const Texture = texture.Texture;
const renderer = @import("renderer.zig");
const selected_api = renderer.api;
const Vector2 = @import("../core/vector2.zig").Vector2;

// -----------------------------------------
//      - FramebufferType -
// -----------------------------------------
pub const FramebufferType = enum{
    Read,
    Draw,
    Both,
};

// -----------------------------------------
//      - FramebufferSpecification -
// -----------------------------------------
pub const FramebufferSpecification = struct {
    width: f32 = 0,
    height: f32 = 0,
    samples: u8 = 0,

    const Self = @This();

    pub fn build(self: *Self, width: f32, height: f32, samples: u8) void {
        self.*.width = width;
        self.*.height = height;
        self.*.samples = samples;
    }
    
};

// -----------------------------------------
//      - FramebufferAttachmentType -
// -----------------------------------------
pub const FramebufferAttachmentType = enum{
    Color0,
    Depth,
    Stencil,
    DepthStencil,
};

// -----------------------------------------
//      - InternalFramebuffer -
// -----------------------------------------
const InternalFramebuffer = union{
    gl: *FramebufferGl,
};

// -----------------------------------------
//      - Framebuffer -
// -----------------------------------------
pub const Framebuffer = struct {

    internal: ?*InternalFramebuffer = undefined,
    specification: ?*FramebufferSpecification = undefined,

    color_attachment: ?*texture.Texture = undefined,

    const Self = @This();

    /// Sets up the Framebuffer and allocates any required memory
    pub fn build(self: *Self, allocator: *std.mem.Allocator) void{
        self.specification = buildFramebufferSpecification(allocator, 1280, 720, 1) catch |err| {
            std.debug.print("[Framebuffer] Failed to create specification! {}\n", .{err});
            return;
        }; 

        switch(selected_api) {
            renderer.BackendApi.OpenGl => {

                // self.internal = &InternalFramebuffer{
                //     .gl = glfb.buildFramebufferOpengl(allocator) catch |err| {
                //         std.debug.print("[Framebuffer] Error occurred during creation! {}\n", .{err});
                //         @panic("[Framebuffer] Failed to create!");
                //     },
                // };
                self.internal = allocator.create(InternalFramebuffer) catch | err | {
                    std.debug.print("[Framebuffer] Error occurred during creation! {}\n", .{err});
                    @panic("[Framebuffer] Failed to create!");
                };

                self.internal.?.gl = glfb.buildFramebufferOpengl(allocator) catch |err| {
                        std.debug.print("[Framebuffer] Error occurred during creation! {}\n", .{err});
                        @panic("[Framebuffer] Failed to create!");
                    };
                // self.internal = &.{
                //     .gl = glfb.buildFramebufferOpengl(allocator) catch |err| {
                //         std.debug.print("[Framebuffer] Error occurred during creation! {}\n", .{err});
                //         @panic("[Framebuffer] Failed to create!");
                //     },
                // };
            },
            renderer.BackendApi.Dx12 => {

            },
            renderer.BackendApi.Vulkan => {

            }
        }
    }

    /// Frees up any allocated memory
    pub fn free(self: *Self, allocator: *std.mem.Allocator) void {
        self.internal.?.gl.free();
        self.color_attachment.?.free(allocator);
        allocator.destroy(self.specification.?);
        allocator.destroy(self.internal.?.gl);
        allocator.destroy(self.internal.?);
        allocator.destroy(self.color_attachment.?);
    }

    /// Binds the framebuffer to perform read/write operations on.
    pub fn bind(self: *Self, target: FramebufferType) void {
        switch(selected_api) {
            renderer.BackendApi.OpenGl => {
                self.internal.?.gl.bind(target);
            },
            renderer.BackendApi.Dx12 => {

            },
            renderer.BackendApi.Vulkan => {

            }
        }
    }

    /// Attaches texture to the framebuffer as the color buffer, depth buffer, and/or stencil buffer.
    pub fn attach2d(self: *Self, id: texture.TextureId, attachment: FramebufferAttachmentType) void {
        switch(selected_api) {
            renderer.BackendApi.OpenGl => {
                self.internal.?.gl.attach2d(id, attachment);
            },
            renderer.BackendApi.Dx12 => {

            },
            renderer.BackendApi.Vulkan => {

            }
        }
    }

    /// Allocates, builds, and attaches a color attachment for the framebuffer. 
    /// Comments: This is one of the few places where the Texture will be owned by 
    /// this class and will be disposed of properly.
    pub fn addColorAttachment(self: *Self, allocator: *std.mem.Allocator, attachment: FramebufferAttachmentType, size: Vector2) void {
        self.color_attachment = texture.buildDatalessTexture(allocator, size) catch | err | {
            std.debug.print("[FRAMEBUFFER]: Error occurred when adding a color attachment! {}\n", .{err});
            return;
        };

        self.attach2d(self.color_attachment.?.getId(), attachment);
    }

    /// Checks to see if the framebuffer if complete
    pub fn check(self: *Self) void {
        switch(selected_api) {
            renderer.BackendApi.OpenGl => {
                self.internal.?.gl.check();
            },
            renderer.BackendApi.Dx12 => {

            },
            renderer.BackendApi.Vulkan => {

            }
        }
    }

    /// Returns the color attachment texture id, if a attachment was NOT set it'll return null
    pub fn getColorAttachment(self: *Self) ?Texture.TextureId {
        if(self.color_attachment == undefined) return null;
        return self.color_attachment.?.getId();
    }

    /// Binds the color attachment texture
    pub fn bindColorAttachment(self: *Self) void {
        self.color_attachment.?.bind();
    }

    /// Clears framebuffer to the default
    pub fn resetFramebuffer() void {
        switch(selected_api) {
            renderer.BackendApi.OpenGl => {
                FramebufferGl.resetFramebuffer();
            },
            renderer.BackendApi.Dx12 => {

            },
            renderer.BackendApi.Vulkan => {

            }
        }
    }

};

pub fn buildFramebuffer(allocator: *std.mem.Allocator) !*Framebuffer {
    var framebuffer = try allocator.create(Framebuffer);

    framebuffer.build(allocator);

    return framebuffer;
}

pub fn buildFramebufferSpecification(allocator: *std.mem.Allocator, width: f32, height: f32, samples: u8) !*FramebufferSpecification {
    var fbs = try allocator.create(FramebufferSpecification);

    fbs.build(width, height, samples);

    return fbs;
}
