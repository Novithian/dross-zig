#version 450 core

layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec4 in_color;
layout (location = 2) in vec2 in_tex;
layout (location = 3) in float in_index;

out vec2 tex_coords;
out vec4 draw_color;
out float tex_index;

uniform mat4 projection;
uniform mat4 view;

void main(){
    // Vclip = Mprojection * Mview * Mmodel * Vlocal
    // Vec4 = M4 * M4 * M4 * Vec4
	
	// Old methods
    //gl_Position = projection_view * model * vec4(in_pos.xy, 0.0, 1.0);
    //gl_Position = projection * view * model * vec4(in_pos.xyz, 1.0);

    gl_Position = projection * view * vec4(in_pos.xyz, 1.0);
	tex_coords = in_tex;
	tex_index = in_index;
	draw_color = in_color;
}
