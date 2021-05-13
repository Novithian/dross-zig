#version 450 core

out vec4 out_color;

in vec2 out_tex;

uniform sampler2D tex;
uniform vec3 sprite_color;

void main(){
	vec4 tex_color = texture(tex, out_tex);
	if(tex_color.a < 0.01)
		discard;
    out_color = tex_color * vec4(sprite_color, 1.0);
}
