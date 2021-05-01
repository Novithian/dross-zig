const std = @import("std");
const c = @cImport({
    @cInclude("glfw3.h");
});

pub fn main() anyerror!u8 {
    if(c.glfwInit() == 0) return 1;
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);

    const window = c.glfwCreateWindow(640, 360, "Dross-zig Application", null, null) orelse return 1;
    defer c.glfwDestroyWindow(window);
    c.glfwMakeContextCurrent(window);

    while(c.glfwWindowShouldClose(window) == 0) {
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    return 0;

}
