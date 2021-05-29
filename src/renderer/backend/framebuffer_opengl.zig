// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
// dross-zig
const FramebufferType = @import("../framebuffer.zig").FramebufferType;
const FramebufferAttachmentType = @import("../framebuffer.zig").FramebufferAttachmentType;
const texture = @import("../texture.zig");
const Texture = texture.Texture;

// -----------------------------------------
//      - FramebufferGl -
// -----------------------------------------
pub const FramebufferGl = struct {
    handle: c_uint = undefined,
    target: c_uint = undefined,
    const Self = @This();

    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var self = try allocator.create(FramebufferGl);

        // Generate the framebuffer handle
        c.glGenFramebuffers(1, &self.handle);

        return self;
    }

    pub fn free(allocator: *std.mem.Allocator, self: *Self) void {
        // Delete the buffer
        c.glDeleteFramebuffers(1, &self.handle);

        allocator.destroy(self);
    }

    /// Binds the framebuffer
    pub fn bind(self: *Self, target: FramebufferType) void {
        self.target = convertBufferType(target);
        // GL_FRAMEBUFFER will make the buffer the target for the next
        // read AND write operations.
        // Other options being GL_READ_FRAMEBUFFER for read, and
        // GL_DRAW_FRAMEBUFFER for write.
        c.glBindFramebuffer(self.target, self.handle);
    }

    /// Attaches texture to the framebuffer as the color buffer, depth buffer, and/or stencil buffer.
    pub fn attach2d(self: *Self, id: texture.TextureId, attachment: FramebufferAttachmentType) void {
        const attachment_convert = convertAttachmentType(attachment);
        c.glFramebufferTexture2D(
            self.target, // Framebuffer type
            attachment_convert, // Attachment Type
            c.GL_TEXTURE_2D, // Texture type
            id.id_gl, // Texture id
            0, // Mipmap level
        );
    }

    /// Checks to see if the framebuffer if complete
    pub fn check(self: *Self) void {
        const status = c.glCheckFramebufferStatus(self.target);
        if (status != c.GL_FRAMEBUFFER_COMPLETE) {
            std.debug.print("[FRAMEBUFFER]: Framebuffer is not yet complete! {}", .{status});
        }
    }

    /// Clears framebuffer to the default
    pub fn resetFramebuffer() void {
        c.glBindFramebuffer(c.GL_FRAMEBUFFER, 0);
    }

    fn convertBufferType(target: FramebufferType) c_uint {
        switch (target) {
            FramebufferType.Both => return c.GL_FRAMEBUFFER,
            FramebufferType.Draw => return c.GL_READ_FRAMEBUFFER,
            FramebufferType.Read => return c.GL_DRAW_FRAMEBUFFER,
        }
    }

    fn convertAttachmentType(attachment: FramebufferAttachmentType) c_uint {
        switch (attachment) {
            FramebufferAttachmentType.Color0 => return c.GL_COLOR_ATTACHMENT0,
            FramebufferAttachmentType.Depth => return c.GL_DEPTH_ATTACHMENT,
            FramebufferAttachmentType.Stencil => return c.GL_STENCIL_ATTACHMENT,
            FramebufferAttachmentType.DepthStencil => return c.GL_DEPTH_STENCIL_ATTACHMENT,
        }
    }
};
