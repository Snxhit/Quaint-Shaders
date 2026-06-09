#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

// ts file procedurally applies vibrancy
    // need to make shadows more normal

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

#include "/lib/definitions.glsl"

vec3 ACESFilm(vec3 x) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

void main() {
    //color.rgb = smoothstep(-0.02, 1.02, texture(colortex0, texcoord).rgb);
    color.rgb = texture(colortex0, texcoord).rgb;

    #if COLOR_MAPPING == 1
        float luminance = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));

        // hardcoded mult
        float saturationMultiplier = 1.55;
        // dynamic
        float satFactor = mix(0.2, 1.55, smoothstep(0.02, 0.25, luminance));
        color.rgb = mix(vec3(luminance), color.rgb, saturationMultiplier);

        vec3 warmGoldTone = vec3(1.06, 1.02, 0.92);
        vec3 darkShadowTone = vec3(0.95, 0.93, 1.05);
        color.rgb = mix(color.rgb * darkShadowTone, color.rgb * warmGoldTone, luminance);

        color.rgb *= 0.92;

        color.rgb = ACESFilm(color.rgb);
    #else
        color.rgb = texture(colortex0, texcoord).rgb;
    #endif
}