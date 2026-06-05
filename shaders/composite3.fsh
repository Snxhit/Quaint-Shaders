/* DRAWBUFFERS:03 */
#version 330 compatibility

// ts seperates bright pixels above a threshold into a texture

uniform sampler2D colortex0;

in vec2 texcoord;

layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 color;

float getLuminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

void main() {
    vec3 pixelColor = texture(colortex0, texcoord).rgb;

    float threshold = 0.5;
    vec3 brightColor = vec3(0.0);

    if (getLuminance(pixelColor) > threshold) {
        brightColor = pixelColor;
    }

    outColor = vec4(pixelColor, 1.0);
    color = vec4(brightColor, 1.0);
}
