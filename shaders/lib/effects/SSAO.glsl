float getNoise(vec2 texcoord) {
    return fract(sin(dot(texcoord, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 getViewPos(vec2 texcoord, mat4 gbufferProjectionInverse) {
    float depth = texture(depthtex0, texcoord).x;
    vec3 ndc = vec3(texcoord, depth) * 2.0 - 1.0;
    vec4 viewPos = gbufferProjectionInverse * vec4(ndc, 1.0);
    return viewPos.xyz / viewPos.w;
}

vec3 applySSAO(sampler2D colortex0, vec2 texcoord, sampler2D depthtex0, mat4 gbufferProjectionInverse, mat4 gbufferProjection) {
    vec3 baseColor = texture(colortex0, texcoord).rgb;
    float depth = texture(depthtex0, texcoord).x;

    if (depth >= 1.0) {
        return baseColor;
    }

    vec3 viewPos = getViewPos(texcoord, gbufferProjectionInverse);

    float occlusion = 0.0;
    const int samples = 16;
    float radius = 0.45;
    float bias = 0.03;

    float angle = getNoise(texcoord * vec2(1920.0, 1808.0));
    float cosA = cos(angle);
    float sinA = sin(angle);
    mat2 rotateMatrix = mat2(cosA, -sinA, sinA, cosA);

    for (int i = 0; i < samples; i++) {
        float index = float(i);
        float phi = index * 2.39996;
        float r = sqrt(index + 0.5) / sqrt(float(samples));

        vec3 sampleOffset = vec3(cos(phi) * r, sin(phi) * r, 0.2 + 0.8 * (index / float(samples)));

        sampleOffset.xy = rotateMatrix * sampleOffset.xy;
        sampleOffset *= radius;

        vec3 samplePos = viewPos + sampleOffset;

        vec4 offsetScreenPos = gbufferProjection * vec4(samplePos, 1.0);
        vec2 sampleTexCoord = (offsetScreenPos.xyz / offsetScreenPos.w).xy * 0.5 + 0.5;

        float actualDepth = getViewPos(sampleTexCoord, gbufferProjectionInverse).z;
        float rangeCheck = smoothstep(0.0, 1.0, radius / abs(viewPos.z - actualDepth));

        if (actualDepth >= samplePos.z + bias) {
            occlusion += 1.0 * rangeCheck;
        }
    }

    float aoFactor = 1.0 - (occlusion / float(samples));
    aoFactor = clamp(aoFactor, 0.0, 1.0);
    aoFactor = pow(clamp(aoFactor, 0.0, 1.0), 2.0);

    float blurTotal = 0.0;
    float totalWeight = 0.0;
    vec2 texelSize = 1.0 / vec2(textureSize(depthtex0, 0));

    for (int x = -1; x <= 2; x++) {
        for (int y = -1; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            float depthCheck = texture(depthtex0, texcoord + offset).x;
            
            float weight = max(0.0, 1.0 - abs(depthCheck - depth) * 200.0);
            blurTotal += aoFactor * weight;
            totalWeight += weight;
        }
    }
    aoFactor = totalWeight > 0.0 ? (blurTotal / totalWeight) : aoFactor;

    vec3 ambientColor = vec3(0.25) * aoFactor;
    vec3 directLighting = vec3(0.75);

    vec3 finalColor = baseColor * (ambientColor + directLighting);

    return finalColor;
}
