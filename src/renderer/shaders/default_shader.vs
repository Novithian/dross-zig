#version 450 core

layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec3 in_color;
layout (location = 2) in vec2 in_tex;

out vec3 vertex_color;
out vec2 out_tex;

uniform mat4 transform;

void main(){
    gl_Position = transform * vec4(in_pos, 1.0);
    vertex_color = in_color;
    out_tex = in_tex;
}