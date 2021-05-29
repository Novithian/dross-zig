// Third Parties
const c = @import("../../c_global.zig").c_imp;
const std = @import("std");
// dross-zig
const tx = @import("../renderer/texture.zig");
const Texture = tx.Texture;
const fnt = @import("../renderer/font/font.zig");
const Font = fnt.Font;
const fs = @import("../utils/file_loader.zig");
// ------------------------------------------------

// -----------------------------------------
//      - ResourceHandler -
// -----------------------------------------

/// The allocator used by the ResourceHandler.
var resource_allocator: *std.mem.Allocator = undefined;
var texture_map: std.StringHashMap(*Texture) = undefined;
var font_map: std.StringHashMap(*Font) = undefined;

pub const ResourceHandler = struct {
    /// Builds the ResourceHandler and allocates and required memory.
    /// Comment: The ResourceHandler will be owned by the engine, and 
    /// all resources allocated by the resource handler are owned
    /// by the ResourceHandler.
    pub fn new(allocator: *std.mem.Allocator) void {
        resource_allocator = allocator;

        // Initialize the cache maps
        texture_map = std.StringHashMap(*Texture).init(allocator);
        font_map = std.StringHashMap(*Font).init(allocator);
    }

    /// Frees the ResourceHandler and deallocates and required memory.
    pub fn free() void {
        var texture_iter = texture_map.iterator();
        var font_iter = font_map.iterator();

        while (texture_iter.next()) |entry| {
            unloadTexture(entry.key);
        }

        while (font_iter.next()) |entry| {
            unloadFont(entry.key);
        }

        font_map.deinit();
        texture_map.deinit();
    }

    /// Loads a texture at the given `path` (relative to build/executable).
    /// Comment: All resources allocated by the resource handler are owned
    /// by the ResourceHandler. The returned Texture pointer is owned and 
    /// released by the ResourceHandler.
    pub fn loadTexture(name: []const u8, path: []const u8) !?*Texture {
        var texture: *Texture = Texture.new(resource_allocator, name, path) catch |err| {
            std.debug.print("[Resource Handler]: Error occurred when loading texture({s})! {}\n", .{ path, err });
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

        Texture.free(resource_allocator, texture_entry.?.value);
    }

    /// Loads a font at the given `path` (relative to build/executable).
    /// Comment: All resources allocated by the resource handler are owned
    /// by the ResourceHandler. The returned font pointer is owned and 
    /// released by the ResourceHandler.
    pub fn loadFont(name: []const u8, path: [*c]const u8) ?*Font {
        var font: *Font = Font.new(resource_allocator, path) catch |err| {
            std.debug.print("[Resource Handler]: Error occurred when loading font({s})! {}\n", .{ path, err });
            return null;
        };

        font_map.put(name, font) catch |err| {
            std.debug.print("[Resource Handler]: Error occurred while adding font({s}) to map!\n", .{path});
            return null;
        };

        return font;
    }

    /// Unloads a font with the name `name`, if found in map.
    /// Will be called automatically at the end of the application's
    /// lifetime, but can be used anytime.
    /// NOTE(devon): Be careful of dangling pointers.
    pub fn unloadFont(name: []const u8) void {
        var font_entry = font_map.remove(name);

        Font.free(resource_allocator, font_entry.?.value);
    }
};
