#version 450 core

layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec2 in_tex;

out vec2 out_tex;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;
uniform vec3 sprite_color;


void main(){
    // Vclip = Mprojection * Mview * Mmodel * Vlocal
    // Vec4 = M4 * M4 * M4 * Vec4
    //gl_Position = projection_view * model * vec4(in_pos.xy, 0.0, 1.0);
    gl_Position = projection * view * model * vec4(in_pos.xyz, 1.0);
    out_tex = in_tex;
}
