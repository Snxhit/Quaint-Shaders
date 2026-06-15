/* DRAWBUFFERS:03 */
#version 330 compatibility

// ts seperates bright pixels above a threshold into a texture

uniform sampler2D colortex0;

#include "/lib/definitions.glsl"

in vec2 texcoord;

layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 color;

float getLuminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

void main() {
    vec3 pixelColor = texture(colortex0, texcoord).rgb;

    #if BLOOM_ON == 1
        vec3 brightColor = vec3(0.0);

        if (getLuminance(pixelColor) > BLOOM_THRESHOLD) {
            brightColor = pixelColor;
        }

        color = vec4(brightColor, 1.0);
    #endif

    outColor = vec4(pixelColor, 1.0);
}
