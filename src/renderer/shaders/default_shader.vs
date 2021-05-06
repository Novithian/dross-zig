#version 450 core

layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec3 in_color;
layout (location = 2) in vec2 in_tex;

out vec3 vertex_color;
out vec2 out_tex;

void main(){
    gl_Position = vec4(in_pos, 1.0);
    vertex_color = in_color;
    out_tex = in_tex;
}