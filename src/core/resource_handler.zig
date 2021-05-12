// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
// dross-zig
const Texture = @import("../renderer/texture.zig");
const fs = @import("../utils/file_loader.zig");
// ------------------------------------------------

// -----------------------------------------
//      - ResourceHandler -
// -----------------------------------------

/// The allocator used by the ResourceHandler.
var resource_allocator: *std.mem.Allocator = undefined;
var texture_map: std.StringHashMap(*Texture.Texture) = undefined;
var font_map: std.StringHashMap(void) = undefined;

pub const ResourceHandler = struct {
    /// Builds the ResourceHandler and allocates and required memory.
    /// Comment: All resources allocated by the resource handler are owned
    /// by the ResourceHandler.
    pub fn build(allocator: *std.mem.Allocator) void {
        resource_allocator = allocator;

        // Initialize the cache maps
        texture_map = std.StringHashMap(*Texture.Texture).init(allocator);
        font_map = std.StringHashMap(void).init(allocator);
    }

    /// Frees the ResourceHandler and deallocates and required memory.
    pub fn free() void {
        //TODO(devon): loop through and free all textures 
        var iterator = texture_map.iterator();
        
        while(iterator.next()) | entry | {
            unloadTexture(entry.key);
        }

        texture_map.deinit();
        font_map.deinit();
    }

    /// Loads a texture at the given `path` (relative to build/executable).
    /// Comment: All resources allocated by the resource handler are owned
    /// by the ResourceHandler. The returned Texture pointer is owned and 
    /// released by the ResourceHandler.
    pub fn loadTexture(name: []const u8, path: []const u8) !?*Texture.Texture {
        var texture: *Texture.Texture = Texture.buildTexture(resource_allocator, name, path) catch | err | {
            std.debug.print("[Resource Handler]: Error occurred when loading texture({s})! {}\n", .{path, err});
            return err;
        };
        try texture_map.put(name, texture);

        return texture;
    }

    /// Unloads a texture with the name `name`, if found in map.
    /// Will be called automatically at end of application, but
    /// can be used when switching scenes.
    pub fn unloadTexture(name: []const u8) void {
        var texture_entry = texture_map.remove(name);

        texture_entry.?.value.free(resource_allocator);
        resource_allocator.destroy(texture_entry.?.value);
    }

    /// Loads a font at the given `path` (relative to build/executable).
    /// Comment: All resources allocated by the resource handler are owned
    /// by the ResourceHandler. The returned font pointer is owned and 
    /// released by the ResourceHandler.
    pub fn loadFont(path: []const u8) ?*Texture {}


    pub fn unloadFont() void {}
};

/// Builds and allocates the ResourceHandler for the application.
/// Comments: The allocated memory will be self-contained.
pub fn buildResourceHandler(allocator: *std.mem.Allocator) !void {
    ResourceHandler.build(allocator);
}

/// Frees the resource handler and any memory it has allocated.
pub fn freeResourceHandler() void {
    ResourceHandler.free();
}
