#version 450 core

layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec4 in_color;
layout (location = 2) in vec2 in_tex;

out vec2 tex_coords;
out vec4 draw_color;

uniform mat4 projection;
uniform mat4 view;
//uniform mat4 model;
//uniform vec3 draw_color;
uniform bool flip_h;


void main(){
    // Vclip = Mprojection * Mview * Mmodel * Vlocal
    // Vec4 = M4 * M4 * M4 * Vec4
    //gl_Position = projection_view * model * vec4(in_pos.xy, 0.0, 1.0);
    //gl_Position = projection * view * model * vec4(in_pos.xyz, 1.0);
    gl_Position = projection * view * vec4(in_pos.xyz, 1.0);
	if(flip_h){
		tex_coords = in_tex;
		tex_coords.x = 1 - tex_coords.x;
	}else{
		tex_coords = in_tex;
	}
	draw_color = in_color;
}
