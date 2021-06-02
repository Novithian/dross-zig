#version 450 core
layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec4 in_color;
layout (location = 2) in vec2 in_tex;
//layout (location = 3) in float in_index;

out vec2 tex_coords;
out vec4 draw_color;
//out float tex_index;

void main() {
    tex_coords = in_tex;
	//tex_index = in_index;
	draw_color = in_color;
    gl_Position = vec4(in_pos.xyz, 1.0);
}
