// applies bloom from just this file, in a single composite psas

#include "/lib/definitions.glsl"

float getLuminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

vec3 extractBright(sampler2D colortex0, vec2 texcoord) {
    vec3 color = texture(colortex0, texcoord).rgb;
    if (getLuminance(color) > BLOOM_THRESHOLD) {
        return color;
    }
    return vec3(0.0);
}

vec3 applySinglePassBloom(sampler2D colortex0, vec2 texcoord, float viewWidth, float viewHeight) {
    #if BLOOM_ON == 1
        vec2 blurScale = 1.0 / (vec2(viewWidth, viewHeight) * 0.25);
        vec3 blurredBloom = vec3(0.0);

        const float weights[5] = float[](0.061, 0.242, 0.383, 0.242, 0.061);
        const float offsets[5] = float[](-2.0, -1.0, 0.0, 1.0, 2.0);

        for (int x = 0; x < 5; x++) {
            for (int y = 0; y < 5; y++) {
                vec2 offset = vec2(offsets[x], offsets[y]) * blurScale;
                vec3 sampledBright = extractBright(colortex0, texcoord + offset);
                float combinedWeight = weights[x] * weights[y];
                blurredBloom += sampledBright * combinedWeight;
            }
        }

        vec3 baseColor = texture(colortex0, texcoord).rgb;
        return baseColor + (blurredBloom * 1.5);
    #else
        return texture(colortex0, texcoord).rgb;
    #endif
}