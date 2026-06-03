#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex2; // normal data from terrain gbuffer
uniform sampler2D depthtex0;
uniform float near;
uniform float far;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

float linearizeDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

void main() {
    // left col
    float topleft = linearizeDepth(texture(depthtex0, vec2(texcoord.x - 1, texcoord.y - 1)).r);
    float left = linearizeDepth(texture(depthtex0, vec2(texcoord.x - 1, texcoord.y)).r);
    float bottomleft = linearizeDepth(texture(depthtex0, vec2(texcoord.x - 1, texcoord.y + 1)).r);
    // mid col
    float top = linearizeDepth(texture(depthtex0, vec2(texcoord.x, texcoord.y + 1)).r);
    float mid = linearizeDepth(texture(depthtex0, texcoord).r);
    float bottom = linearizeDepth(texture(depthtex0, vec2(texcoord.x, texcoord.y - 1)).r);
    // right col
    float topright = linearizeDepth(texture(depthtex0, vec2(texcoord.x + 1, texcoord.y - 1)).r);
    float right = linearizeDepth(texture(depthtex0, vec2(texcoord.x + 1, texcoord.y)).r);
    float bottomright = linearizeDepth(texture(depthtex0, vec2(texcoord.x + 1, texcoord.y + 1)).r);

    color.rgb = texture(colortex0, texcoord);
}