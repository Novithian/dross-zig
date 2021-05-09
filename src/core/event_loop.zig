// -----------------------------------------
//      - EventLoop -
// -----------------------------------------

/// The user-defined lifetime event that runs once a frame.
/// Defined in your project to run your game logic.
extern fn update(delta: f64) void;

/// Defined in your project to give control over rendering order.
/// The user-defined lifetime event that runs once a frame.
extern fn render() void;

pub fn updateInternal(delta: f64) void {
    update(delta);
}

pub fn renderInternal() void {
    render();
}
