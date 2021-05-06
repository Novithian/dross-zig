#version 450 core

out vec4 out_color;

in vec3 vertex_color;
in vec2 out_tex;

uniform sampler2D tex;

void main(){
    out_color = texture(tex, out_tex) * vec4(vertex_color, 1.0);
}