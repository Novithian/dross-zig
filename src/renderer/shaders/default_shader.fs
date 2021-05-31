#version 450 core

out vec4 out_color;

in vec2 tex_coords;
in vec4 draw_color;

uniform sampler2D tex;
//uniform vec3 draw_color;

void main(){
	//vec4 tex_color = texture(tex, tex_coords);
	//if(tex_color.a < 0.01)
	//	discard;
    //out_color = tex_color * vec4(sprite_color, 1.0);
	out_color = draw_color;
}
