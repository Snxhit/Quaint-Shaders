/*
Sobel kernels are used for edge detection
-1 0 1
-2 0 2
-1 0 1
and
1   0  0
0   0  0
-1 -2 -1

gradients are calculated w them
*/

#include "/lib/definitions.glsl"

float linearizeDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

int getBlockId(vec2 coord) {
    float sampledId = texture(colortex4, coord).x;
    if (sampledId < -0.5) {
        return -1;
    }
    return int(sampledId + 0.5);
}

vec3 edgeDetect(int dimension, sampler2D colortex0, sampler2D depthtex0, vec2 texcoord, float viewWidth, float viewHeight, int excludedBlockID) {
    /* use dimension int to change variables to tweak effects for each biome */
    /* lets go w: 0 - overworld, 1 - nether, 2 - end */
    // ts better than having copied code for all 3 dimensions
    vec2 texelsize = vec2(1.0 / viewWidth, 1.0 / viewHeight) * EDGE_SIZE;

    // exclusion filter
    float exclusionFilter = 1.0;

    if (getBlockId(texcoord + vec2(-1.0, -1.0) * texelsize) == excludedBlockID || 
        getBlockId(texcoord + vec2(-1.0, 0.0) * texelsize) == excludedBlockID ||
        getBlockId(texcoord + vec2(-1.0, 1.0) * texelsize) == excludedBlockID ||
        getBlockId(texcoord + vec2(0.0, 1.0) * texelsize) == excludedBlockID ||
        getBlockId(texcoord + vec2(0.0, 0.0) * texelsize) == excludedBlockID ||
        getBlockId(texcoord + vec2(0.0, -1.0) * texelsize) == excludedBlockID ||
        getBlockId(texcoord + vec2(1.0, -1.0) * texelsize) == excludedBlockID ||
        getBlockId(texcoord + vec2(1.0, 0.0) * texelsize) == excludedBlockID ||
        getBlockId(texcoord + vec2(1.0, 1.0) * texelsize) == excludedBlockID) {
            exclusionFilter = 0.0;
        }
    // left col
    float topleft = linearizeDepth(texture(depthtex0, texcoord + vec2(-1.0, -1.0) * texelsize).r);
    float left = linearizeDepth(texture(depthtex0, texcoord + vec2(-1.0, 0.0) * texelsize).r);
    float bottomleft = linearizeDepth(texture(depthtex0, texcoord + vec2(-1.0, 1.0) * texelsize).r);
    // mid col
    float top = linearizeDepth(texture(depthtex0, texcoord + vec2(0.0, 1.0) * texelsize).r);
    float mid = linearizeDepth(texture(depthtex0, texcoord + vec2(0.0, 0.0) * texelsize).r);
    float bottom = linearizeDepth(texture(depthtex0, texcoord + vec2(0.0, -1.0) * texelsize).r);
    // right col
    float topright = linearizeDepth(texture(depthtex0, texcoord + vec2(1.0, -1.0) * texelsize).r);
    float right = linearizeDepth(texture(depthtex0, texcoord + vec2(1.0, 0.0) * texelsize).r);
    float bottomright = linearizeDepth(texture(depthtex0, texcoord + vec2(1.0, 1.0) * texelsize).r);

    float horizontalgradient = -topleft + topright - (2 * left) + (2 * right) - bottomleft + bottomright;
    float verticalgradient = topleft + (2 * top) + topright - bottomleft - (2 * bottom) - bottomright;
    float gradientmagnitude = sqrt((horizontalgradient * horizontalgradient) + (verticalgradient * verticalgradient));
    gradientmagnitude /= max(mid * 0.1, 1.0);

    #if EXCLUDE_FOLIAGE == 1
        gradientmagnitude *= exclusionFilter;
    #endif

    float edgeFactor = smoothstep(0.3, 0.7, gradientmagnitude);

    vec3 baseColor = texture(colortex0, texcoord).rgb;
    vec3 outlineColor = mix(baseColor, vec3(1.0), 0.5);
    float outlineAlpha = 0.6;

    // todo:
    // - leaf block holes are exempt
    // - make it smoother
    // - color it according to the block colors

    if (linearizeDepth(texture(depthtex0, texcoord).r) > EDGE_DETECTION_STRENGTH) {
        return(texture(colortex0, texcoord).rgb);
    }

    if (gradientmagnitude > 0.01) {
        //below is the og one
        //color.rgb = mix(baseColor, outlineColor, edgeFactor * outlineAlpha);
        return(baseColor.rgb * EDGE_BRIGHTNESS);
    } else {
        return(texture(colortex0, texcoord).rgb);
    }
}

vec3 edgeDetectRewrite(int dimension, sampler2D colortex0, sampler2D depthtex0, vec2 texcoord, float viewWidth, float viewHeight, int excludedBlockID) {
    // rewrite to fix block faces being detected as edges
}