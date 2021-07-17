#version 450 core
// .xy for the position and .zw for the texture coords
layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec4 in_color;
layout (location = 2) in vec2 in_tex;
layout (location = 3) in float in_index;

out vec2 tex_coords;
out vec4 draw_color;
out float tex_index;

uniform mat4 projection;

void main() {
    gl_Position = projection * vec4(in_pos.xy, 0.0, 1.0);
    tex_coords = in_tex;
	draw_color = in_color;
	tex_index = in_index;
}
