/* DRAWBUFFERS:0 */
#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform float viewHeight;

#include "/lib/definitions.glsl"

in vec2 texcoord;

layout(location = 0) out vec4 color;

void main() {
    #if BLOOM_ON == 1
        float blurSize = 1.0 / (viewHeight * 0.25);
        vec3 verticalBlur = vec3(0.0);

        verticalBlur += texture(colortex3, vec2(texcoord.x, texcoord.y - 2.0 * blurSize)).rgb * 0.061;
        verticalBlur += texture(colortex3, vec2(texcoord.x, texcoord.y - 1.0 * blurSize)).rgb * 0.242;
        verticalBlur += texture(colortex3, vec2(texcoord.x, texcoord.y)).rgb * 0.383;
        verticalBlur += texture(colortex3, vec2(texcoord.x, texcoord.y + 1.0 * blurSize)).rgb * 0.242;
        verticalBlur += texture(colortex3, vec2(texcoord.x, texcoord.y + 2.0 * blurSize)).rgb * 0.061;

        vec3 baseColor = texture(colortex0, texcoord).rgb;

        vec3 finalColor = baseColor + (verticalBlur * 1.5);

        color = vec4(finalColor, 1.0);
    #else
        color.rgb = texture(colortex0, texcoord).rgb;
    #endif
}