// ts file for chromatic aberration

#include "/lib/definitions.glsl"

vec4 applyAberration(int dimension, sampler2D colortex0, vec2 texcoord) {
    vec4 color = texture(colortex0, texcoord);

    #if CHROMATIC_ABERRATION == 1
        vec2 toPixel = texcoord - vec2(0.5, 0.5);
        float falloff = dot(toPixel, toPixel);
        vec2 coordOffset = toPixel * falloff * CHROMATIC_ABERRATION_STRENGTH;

        vec2 rCoord = texcoord + coordOffset;
        vec2 bCoord = texcoord - coordOffset;

        if (rCoord.x >= 0.0 && rCoord.x <= 1.0 && rCoord.y >= 0.0 && rCoord.y <= 1.0 && bCoord.x >= 0.0 && bCoord.x <= 1.0 && bCoord.y >= 0.0 && bCoord.y <= 1.0) {
            float r = texture(colortex0, texcoord + coordOffset).r;
            float g = texture(colortex0, texcoord).g;
            float b = texture(colortex0, texcoord - coordOffset).b;
            float a = texture(colortex0, texcoord).a;
           
            color = vec4(r, g, b, a);
        }
    #endif

    return color;
}