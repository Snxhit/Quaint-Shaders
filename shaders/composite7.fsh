#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

void main() {
    color.rgb = smoothstep(-0.02, 1.02, texture(colortex0, texcoord).rgb);

    float luminance = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));

    float saturationMultiplier = 1.55;
    color.rgb = mix(vec3(luminance), color.rgb, saturationMultiplier);

    vec3 warmGoldTone = vec3(1.06, 1.02, 0.92);
    vec3 darkShadowTone = vec3(0.92, 0.90, 1.05);
    color.rgb = mix(color.rgb * darkShadowTone, color.rgb * warmGoldTone, luminance);

    color.rgb *= 0.92;
}