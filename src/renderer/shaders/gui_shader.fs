#version 450 core

out vec4 color;

in vec2 tex_coords;
in vec4 draw_color;
in float tex_index;

uniform sampler2D texture_slots[32];

void main() {
	//vec4 tex_color = texture(tex, tex_coords);
	vec4 tex_color = texture(texture_slots[int(tex_index)], tex_coords);
	if(tex_color.a < 0.01)
		discard;
    color = tex_color * draw_color;
}
