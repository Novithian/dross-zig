#version 450 core

out vec4 out_color;

in vec2 tex_coords;
in vec4 draw_color;
in float tex_index;

uniform sampler2D texture_slots[32];

void main(){
	//vec4 tex_color = texture(texture_slots, tex_coords);
	//if(tex_color.a < 0.01)
	//	discard;
    //out_color = tex_color * vec4(sprite_color, 1.0);
	out_color = texture(texture_slots[int(tex_index)], tex_coords) * draw_color;
}
