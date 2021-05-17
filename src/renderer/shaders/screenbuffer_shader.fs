#version 450 core

out vec4 color;

in vec2 tex_coords;

uniform sampler2D screen_texture;

void main() {
    vec3 opaque_color = texture(screen_texture, tex_coords).rgb;
    color = vec4(opaque_color, 1.0);
}