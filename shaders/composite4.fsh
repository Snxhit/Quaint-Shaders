/* DRAWBUFFERS:03 */
#version 330 compatibility

// ts pass handles blurring extracted texture in x axis

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform float viewWidth;

in vec2 texcoord;

layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 color;

void main() {
    float blurSize = 1.0 / (viewWidth * 0.25);
    vec3 sum = vec3(0.0);

    sum += texture(colortex3, vec2(texcoord.x - 2.0 * blurSize, texcoord.y)).rgb * 0.061;
    sum += texture(colortex3, vec2(texcoord.x - 1.0 * blurSize, texcoord.y)).rgb * 0.242;
    sum += texture(colortex3, vec2(texcoord.x, texcoord.y)).rgb * 0.383;
    sum += texture(colortex3, vec2(texcoord.x + 1.0 * blurSize, texcoord.y)).rgb * 0.242;
    sum += texture(colortex3, vec2(texcoord.x + 2.0 * blurSize, texcoord.y)).rgb * 0.061;

    outColor = texture(colortex0, texcoord);
    color = vec4(sum, 1.0);
}
