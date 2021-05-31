#version 450 core
layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec4 in_color;
layout (location = 2) in vec2 in_tex;

out vec2 tex_coords;
out vec4 draw_color;

void main() {
    tex_coords = in_tex;
	draw_color = in_color;
    gl_Position = vec4(in_pos.xyz, 1.0);
}
