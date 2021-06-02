#version 450 core

out vec4 color;

in vec2 tex_coords;
in vec4 draw_color;
//in float tex_index;

uniform sampler2D tex;

void main() {
	//vec3 opaque_color = texture(tex[int(tex_index)], tex_coords).rgb;
    vec3 opaque_color = texture(tex, tex_coords).rgb;
    color = vec4(opaque_color, 1.0);
}
