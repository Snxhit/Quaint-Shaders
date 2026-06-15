#version 330 compatibility

// ts file for chromatic aberration

uniform sampler2D colortex0;

in vec2 texcoord;

#include "/lib/definitions.glsl"

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

void main() {
    #if CHROMATIC_ABERRATION == 1
        vec2 toPixel = texcoord - vec2(0.5, 0.5);
        float falloff = dot(toPixel, toPixel);
        vec2 coordOffset = toPixel * falloff * CHROMATIC_ABERRATION_STRENGTH;

        float r = texture(colortex0, texcoord + coordOffset).r;
        float g = texture(colortex0, texcoord).g;
        float b = texture(colortex0, texcoord - coordOffset).b;
        float a = texture(colortex0, texcoord).a;

        color = vec4(r, g, b, a);
    #else
        color.rgb = texture(colortex0, texcoord).rgb;
    #endif
}