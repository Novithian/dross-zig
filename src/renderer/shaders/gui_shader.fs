#version 450 core

out vec4 color;

in vec2 tex_coords;

uniform sampler2D tex;
uniform vec3 draw_color;

void main() {
	vec4 tex_color = texture(tex, tex_coords);
	if(tex_color.a < 0.01)
		discard;
    color = tex_color * vec4(draw_color, 1.0);
}
