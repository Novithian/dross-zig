#version 450 core

out vec4 color;

in vec2 tex_coords;
in vec4 text_color;
in float tex_index;

//uniform sampler2D text;
uniform sampler2D texture_slots[32];

void main() {
    vec4 sampled_color = vec4( 1.0, 1.0, 1.0, texture( texture_slots[int(tex_index)], tex_coords ).r );
	//vec4 sampled_color = texture(text, tex_coords);
    //color = vec4( text_color, 1.0 ) * sampled_color;
	color = text_color * sampled_color;
}
