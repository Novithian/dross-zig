// Third Parties
const std = @import("std");
const c = @import("../c_global.zig").c_imp;
// dross-zig
const Application = @import("application.zig").Application;
const Vector2 = @import("vector2.zig").Vector2;
// ---------------------------------------------------------

// -----------------------------------------
//      - Input -
// -----------------------------------------
/// Input wrapper for GLFW
pub const Input = struct {
    /// Returns true if the key in question is currently pressed.
    pub fn keyPressed(key: DrossKey) bool {
        var state = key_map.get(key).?;
        return state == DrossInputState.Pressed or state == DrossInputState.Down;
    }

    /// Returns the f32 value version of getKeyPressed
    pub fn keyPressedValue(key: DrossKey) f32 {
        const key_pressed = keyPressed(key);
        return @intToFloat(f32, @boolToInt(key_pressed));
    }

    /// Returns true if the key in question was just released.
    pub fn keyReleased(key: DrossKey) bool {
        return key_released_set.contains(key);
    }

    /// Returns the f32 value version of getKeyReleased
    pub fn keyReleasedValue(key: DrossKey) f32 {
        const key_released = keyReleased(key);
        return @intToFloat(f32, @boolToInt(key_released));
    }

    /// Returns true if the key in question is registered has held 
    /// down (takes a few frames to register).
    pub fn keyDown(key: DrossKey) bool {
        var state = key_map.get(key).?;
        return state == DrossInputState.Down;
    }

    /// Returns the f32 value version of getKeyDown
    pub fn keyDownValue(key: DrossKey) f32 {
        const key_down = keyDown(key);
        return @intToFloat(f32, @boolToInt(key_down));
    }

    /// Returns the Mouse's position as a Vector2
    /// The position is in screen coordinates (relative to the left bounds)
    /// and top bounds of the content area.
    pub fn mousePosition() Vector2 {
        return mouse_position;
    }

    /// Returns if the mouse button has been pressed this frame
    pub fn mouseButtonPressed(button: DrossMouseButton) bool {
        const state = mouse_button_map.get(button).?;
        return state == DrossInputState.Pressed or state == DrossInputState.Down;
    }

    /// Returns if the mouse button has been held down for multiple frames
    /// NOTE(devon): Currently does not work!
    /// TODO(devon): Create a timer to find out if the button has 
    /// be held down for multiple frames.
    pub fn mouseButtonDown(button: DrossMouseButton) bool {
        const state = mouse_button_map.get(button).?;
        return state == DrossInputState.Down;
    }

    /// Returns if the mouse button has been released this frame
    pub fn mouseButtonReleased(button: DrossMouseButton) bool {
        return mouse_button_released_set.contains(button);
    }

    /// Allocates and builds the required components for the Input system.
    /// Comments: Any allocated memory will be owned by the Input System.
    pub fn new(allocator: *std.mem.Allocator) !void {
        // Connect the callbacks
        _ = c.glfwSetKeyCallback(Application.window(), keyCallback);
        _ = c.glfwSetCursorPosCallback(Application.window(), mousePositionCallback);
        _ = c.glfwSetMouseButtonCallback(Application.window(), mouseButtonCallback);

        // Initialize the mouse-related
        mouse_position = Vector2.new(0.0, 0.0);
        mouse_button_map = std.AutoHashMap(DrossMouseButton, DrossInputState).init(allocator);
        mouse_button_released_set = std.AutoHashMap(DrossMouseButton, void).init(allocator);

        // Initialize the key maps
        key_map = std.AutoHashMap(DrossKey, DrossInputState).init(allocator);
        key_released_set = std.AutoHashMap(DrossKey, void).init(allocator);

        // Populate the mouse button map
        try mouse_button_map.put(DrossMouseButton.MouseButtonLeft, DrossInputState.Neutral);
        try mouse_button_map.put(DrossMouseButton.MouseButtonRight, DrossInputState.Neutral);
        try mouse_button_map.put(DrossMouseButton.MouseButtonMiddle, DrossInputState.Neutral);
        try mouse_button_map.put(DrossMouseButton.MouseButton4, DrossInputState.Neutral);
        try mouse_button_map.put(DrossMouseButton.MouseButton5, DrossInputState.Neutral);
        try mouse_button_map.put(DrossMouseButton.MouseButton6, DrossInputState.Neutral);
        try mouse_button_map.put(DrossMouseButton.MouseButton7, DrossInputState.Neutral);
        try mouse_button_map.put(DrossMouseButton.MouseButton8, DrossInputState.Neutral);

        // Populate the keyboard map
        try key_map.put(DrossKey.KeyF1, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF2, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF3, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF4, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF5, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF6, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF7, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF8, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF9, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF10, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF11, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF12, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF13, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF14, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF15, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF16, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF17, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF18, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF19, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF20, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF21, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF22, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF23, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF24, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF25, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyA, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyB, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyC, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyD, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyE, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyF, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyG, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyH, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyI, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyJ, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyK, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyL, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyM, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyN, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyO, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyP, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyQ, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyR, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyS, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyT, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyU, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyV, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyW, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyX, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyY, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyZ, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyUnknown, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeySpace, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyApostrophe, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyComma, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyMinus, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyPeriod, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeySlash, DrossInputState.Neutral);
        try key_map.put(DrossKey.Key0, DrossInputState.Neutral);
        try key_map.put(DrossKey.Key1, DrossInputState.Neutral);
        try key_map.put(DrossKey.Key2, DrossInputState.Neutral);
        try key_map.put(DrossKey.Key3, DrossInputState.Neutral);
        try key_map.put(DrossKey.Key4, DrossInputState.Neutral);
        try key_map.put(DrossKey.Key5, DrossInputState.Neutral);
        try key_map.put(DrossKey.Key6, DrossInputState.Neutral);
        try key_map.put(DrossKey.Key7, DrossInputState.Neutral);
        try key_map.put(DrossKey.Key8, DrossInputState.Neutral);
        try key_map.put(DrossKey.Key9, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeySemiColon, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyEqual, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyLeftBracket, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyBackslash, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyRightBracket, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyBacktick, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyWorld1, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyWorld2, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyEscape, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyEnter, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyTab, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyBackspace, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyInsert, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyDelete, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyRight, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyLeft, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyUp, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyDown, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyPageUp, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyPageDown, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyHome, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyEnd, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyCapsLock, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyScrollLock, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyNumLock, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyPrintScreen, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyPause, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypad0, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypad1, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypad2, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypad3, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypad4, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypad5, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypad6, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypad7, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypad8, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypad9, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypadDecimal, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypadDivide, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypadMultiply, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypadSubtract, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypadAdd, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypadEnter, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyKeypadEqual, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyLeftShift, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyLeftControl, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyLeftAlt, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyLeftSuper, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyRightShift, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyRightControl, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyRightAlt, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyRightSuper, DrossInputState.Neutral);
        try key_map.put(DrossKey.KeyMenu, DrossInputState.Neutral);
    }

    /// Frees any allocated memory that was required for Input
    pub fn free(allocator: *std.mem.Allocator) void {
        mouse_button_map.deinit();
        mouse_button_released_set.deinit();
        key_map.deinit();
        key_released_set.deinit();
    }

    /// Updates the cached input states
    pub fn updateInput() void {
        updateReleasedMouseButtons();
        updateReleasedKeys();
    }
};

/// The possible states of input
const DrossInputState = enum(u8) {
    /// If the input is in the default position and has not been changed 
    Neutral = 3,
    /// If the input just pressed this frame
    Pressed = c.GLFW_PRESS,
    /// If the input was released this frame
    Released = c.GLFW_RELEASE,
    /// If the input was help for multiple frames
    Down = c.GLFW_REPEAT,
};

// --------------------------------------------------------
//      - Mouse Specific -
// --------------------------------------------------------

/// Stores the mouse position in screen coordinates (relative to the bound 
/// of the content area).
var mouse_position: Vector2 = undefined;

/// Holds the most recent mouse button states
var mouse_button_map: std.AutoHashMap(DrossMouseButton, DrossInputState) = undefined;

/// A HashSet that holds any mouse buttons that have recently 
/// been released. Released only needs to be held for frame or so, and 
/// then any mouse buttons stored will be set to neutral.
var mouse_button_released_set: std.AutoHashMap(DrossMouseButton, void) = undefined;

/// Wrapper for the numerical values representing the mouse buttons.
pub const DrossMouseButton = enum(u8) {
    MouseButtonLeft = 0,
    MouseButtonRight = 1,
    MouseButtonMiddle = 2,
    MouseButton4 = 3,
    MouseButton5 = 4,
    MouseButton6 = 5,
    MouseButton7 = 6,
    MouseButton8 = 7,
};

/// Checks for any released mouse buttons from the previous frame, and resets them to neutral.
fn updateReleasedMouseButtons() void {
    if (mouse_button_released_set.count() == 0) return;

    // Cycle through the released map
    var iterator = mouse_button_released_set.iterator();
    while (iterator.next()) |entry| {
        const key = entry.key;
        // Check if the state of the mouse button has changed from released to pressed or down
        const current_state = mouse_button_map.get(key).?;
        // If it has not changed, then set it to neutral.
        if (current_state == DrossInputState.Released) {
            mouse_button_map.put(key, DrossInputState.Neutral) catch |err| {
                if (err == error.OutOfMemory) @panic("[Input] Ran out of memory when trying put into mouse button state map!");
            };
        }
        // Otherwise, leave the state alone and just remove all keys at the end.
        _ = mouse_button_released_set.remove(key);
    }
}

/// The mouse position callback for GLFW.
/// Comments: INTERNAL use only.
pub fn mousePositionCallback(window: ?*c.GLFWwindow, x_pos: f64, y_pos: f64) callconv(.C) void {
    mouse_position = Vector2.new(@floatCast(f32, x_pos), @floatCast(f32, y_pos));
}

/// The mouse button callback for GLFW.
/// Comments: INTERNAL use only.
pub fn mouseButtonCallback(window: ?*c.GLFWwindow, button: c_int, action: c_int, mods: c_int) callconv(.C) void {
    const button_convert = @intCast(u8, button);
    const button_enum = @intToEnum(DrossMouseButton, button_convert);
    if (mouse_button_map.contains(button_enum)) {
        if (action == c.GLFW_PRESS) {
            mouse_button_map.put(button_enum, DrossInputState.Pressed) catch |err| {
                if (err == error.OutOfMemory) @panic("[Input] Ran out of memory when trying put into mouse button state map!");
            };
        } else if (action == c.GLFW_RELEASE) {
            mouse_button_map.put(button_enum, DrossInputState.Released) catch |err| {
                if (err == error.OutOfMemory) @panic("[Input] Ran out of memory when trying put into mouse button state map!");
            };
            mouse_button_released_set.put(button_enum, {}) catch |err| {
                if (err == error.OutOfMemory) @panic("[Input] Ran out of memory when trying put into mouse button state map!");
            };
        } else if (action == c.GLFW_REPEAT) {
            mouse_button_map.put(button_enum, DrossInputState.Down) catch |err| {
                if (err == error.OutOfMemory) @panic("[Input] Ran out of memory when trying put into mouse button state map!");
            };
        }
    }
}

// --------------------------------------------------------
//      - Keyboard Specific -
// --------------------------------------------------------

/// Holds the most recent key states
var key_map: std.AutoHashMap(DrossKey, DrossInputState) = undefined;

/// A HashSet that holds any keys that have recently been released. 
/// Released only needs to be held for frame or so, and 
/// then any keys stored will be set to neutral.
var key_released_set: std.AutoHashMap(DrossKey, void) = undefined;

/// Checks for any released keys from the previous frame, and resets them to neutral.
fn updateReleasedKeys() void {
    if (key_released_set.count() == 0) return;

    // Cycle through the released map
    var iterator = key_released_set.iterator();
    while (iterator.next()) |entry| {
        const key = entry.key;
        // Check if the state of the key has changed from released to pressed or down
        const current_state = key_map.get(key).?;
        // If it has not changed, then set it to neutral.
        if (current_state == DrossInputState.Released) {
            key_map.put(key, DrossInputState.Neutral) catch |err| {
                if (err == error.OutOfMemory) @panic("[Input] Ran out of memory when trying put into key state map!");
            };
        }
        // Otherwise, leave the state alone and just remove all keys at the end.
        _ = key_released_set.remove(key);
    }
}

/// The key callback for GLFW so that we can more accurately keep track of key states.
/// Comments: INTERNAL use only.
pub fn keyCallback(window: ?*c.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.C) void {
    const key_convert = @intCast(i16, key);
    const key_enum = @intToEnum(DrossKey, key_convert);
    if (key_map.contains(key_enum)) {
        if (action == c.GLFW_PRESS) {
            key_map.put(key_enum, DrossInputState.Pressed) catch |err| {
                if (err == error.OutOfMemory) @panic("[Input] Ran out of memory when trying put into key state map!");
            };
        } else if (action == c.GLFW_RELEASE) {
            key_map.put(key_enum, DrossInputState.Released) catch |err| {
                if (err == error.OutOfMemory) @panic("[Input] Ran out of memory when trying put into key state map!");
            };
            key_released_set.put(key_enum, {}) catch |err| {
                if (err == error.OutOfMemory) @panic("[Input] Ran out of memory when trying put into key state map!");
            };
        } else if (action == c.GLFW_REPEAT) {
            key_map.put(key_enum, DrossInputState.Down) catch |err| {
                if (err == error.OutOfMemory) @panic("[Input] Ran out of memory when trying put into key state map!");
            };
        }
    }
}

/// Keycode wrapper for GLFW
// zig fmt: off
pub const DrossKey = enum(i16){
    KeyUnknown          = -1,  
    KeySpace            = 32,
    KeyApostrophe       = 39, // '
    KeyComma            = 44, // ,
    KeyMinus            = 45, // -
    KeyPeriod           = 46, // .
    KeySlash            = 47, // /
    Key0                = 48,
    Key1                = 49,
    Key2                = 50,
    Key3                = 51,
    Key4                = 52,
    Key5                = 53,
    Key6                = 54,
    Key7                = 55,
    Key8                = 56,
    Key9                = 57,
    KeySemiColon        = 59, // ;
    KeyEqual            = 61, // =
    KeyA                = 65,
    KeyB                = 66,
    KeyC                = 67,
    KeyD                = 68,
    KeyE                = 69,
    KeyF                = 70,
    KeyG                = 71,
    KeyH                = 72,
    KeyI                = 73,
    KeyJ                = 74,
    KeyK                = 75,
    KeyL                = 76,
    KeyM                = 77,
    KeyN                = 78,
    KeyO                = 79,
    KeyP                = 80,
    KeyQ                = 81,
    KeyR                = 82,
    KeyS                = 83,
    KeyT                = 84,
    KeyU                = 85,
    KeyV                = 86,
    KeyW                = 87,
    KeyX                = 88,
    KeyY                = 89,
    KeyZ                = 90,
    KeyLeftBracket      = 91, // [
    KeyBackslash        = 92, // \
    KeyRightBracket     = 93, // ]
    KeyBacktick         = 96, // `
    KeyWorld1           = 161, //non-US #1
    KeyWorld2           = 162, //non-US #2
    KeyEscape           = 256, 
    KeyEnter            = 257,
    KeyTab              = 258,
    KeyBackspace        = 259,
    KeyInsert           = 260,
    KeyDelete           = 261,
    KeyRight            = 262,
    KeyLeft             = 263,
    KeyDown             = 264,
    KeyUp               = 265,
    KeyPageUp           = 266,
    KeyPageDown         = 267,
    KeyHome             = 268,
    KeyEnd              = 269,
    KeyCapsLock         = 280,
    KeyScrollLock       = 281,
    KeyNumLock          = 282,
    KeyPrintScreen      = 283,
    KeyPause            = 284,
    KeyF1               = 290,
    KeyF2               = 291,
    KeyF3               = 292,
    KeyF4               = 293,
    KeyF5               = 294,
    KeyF6               = 295,
    KeyF7               = 296,
    KeyF8               = 297,
    KeyF9               = 298,
    KeyF10              = 299,
    KeyF11              = 300,
    KeyF12              = 301,
    KeyF13              = 302,
    KeyF14              = 303,
    KeyF15              = 304,
    KeyF16              = 305,
    KeyF17              = 306,
    KeyF18              = 307,
    KeyF19              = 308,
    KeyF20              = 309,
    KeyF21              = 310,
    KeyF22              = 311,
    KeyF23              = 312,
    KeyF24              = 313,
    KeyF25              = 314,
    KeyKeypad0          = 320,
    KeyKeypad1          = 321,
    KeyKeypad2          = 322,
    KeyKeypad3          = 323,
    KeyKeypad4          = 324,
    KeyKeypad5          = 325,
    KeyKeypad6          = 326,
    KeyKeypad7          = 327,
    KeyKeypad8          = 328,
    KeyKeypad9          = 329,
    KeyKeypadDecimal    = 330,
    KeyKeypadDivide     = 331,
    KeyKeypadMultiply   = 332,
    KeyKeypadSubtract   = 333,
    KeyKeypadAdd        = 334,
    KeyKeypadEnter      = 335,
    KeyKeypadEqual      = 336,
    KeyLeftShift        = 340,
    KeyLeftControl      = 341,
    KeyLeftAlt          = 342,
    KeyLeftSuper        = 343,
    KeyRightShift       = 344,
    KeyRightControl     = 345,
    KeyRightAlt         = 346,
    KeyRightSuper       = 347,
    KeyMenu             = 348,
};
