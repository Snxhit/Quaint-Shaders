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

vec3 edgeDetectDepth(int dimension, vec3 color, sampler2D depthtex0, vec2 texcoord, float viewWidth, float viewHeight, int excludedBlockID);
vec3 edgeDetectDepthNormal(int dimension, vec3 color, sampler2D colortex2, sampler2D depthtex0, vec2 texcoord, float viewWidth, float viewHeight, int excludedBlockID);

vec3 edgeDetect(int dimension, vec3 color, sampler2D colortex2, sampler2D depthtex0, vec2 texcoord, float viewWidth, float viewHeight, int excludedBlockID) {
    #if EDGE_DETECTION == 1
        #if EDGE_DETECTION_MODE == 0
            return(edgeDetectDepth(dimension, color, depthtex0, texcoord, viewWidth, viewHeight, excludedBlockID));
        #elif EDGE_DETECTION_MODE == 1
            return(edgeDetectDepthNormal(dimension, color, colortex2, depthtex0, texcoord, viewWidth, viewHeight, excludedBlockID));
        #endif
    #else
        return color;
    #endif
}

vec3 edgeDetectDepth(int dimension, vec3 color, sampler2D depthtex0, vec2 texcoord, float viewWidth, float viewHeight, int excludedBlockID) {
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

    vec3 outlineColor = mix(color, vec3(1.0), 0.5);
    float outlineAlpha = 0.6;

    // todo:
    // - leaf block holes are exempt
    // - make it smoother
    // - color it according to the block colors

    if (linearizeDepth(texture(depthtex0, texcoord).r) > EDGE_DETECTION_STRENGTH) {
        return color;
    }

    if (gradientmagnitude > 0.01) {
        //below is the og one
        //color.rgb = mix(baseColor, outlineColor, edgeFactor * outlineAlpha);
        return color.rgb * EDGE_BRIGHTNESS;
    } else {
        return color;
    }
}

vec3 edgeDetectDepthNormal(int dimension, vec3 color, sampler2D colortex2, sampler2D depthtex0, vec2 texcoord, float viewWidth, float viewHeight, int excludedBlockID) {
    // rewrite to fix block faces being detected as edges
    vec2 texelsize = vec2(1.0 / viewWidth, 1.0 / viewHeight) * EDGE_SIZE;

    float exclusionFilter = 1.0;

    #if EXCLUDE_FOLIAGE == 1
        if (getBlockId(texcoord + vec2(-1.0, -1.0) * texelsize) == excludedBlockID ||
            getBlockId(texcoord + vec2(-1.0, 0.0) * texelsize) == excludedBlockID ||
            getBlockId(texcoord + vec2(-1.0, 1.0) * texelsize) == excludedBlockID ||
            getBlockId(texcoord + vec2(0.0, 1.0) * texelsize) == excludedBlockID ||
            getBlockId(texcoord) == excludedBlockID ||
            getBlockId(texcoord + vec2(0.0, -1.0) * texelsize) == excludedBlockID ||
            getBlockId(texcoord + vec2(1.0, -1.0) * texelsize) == excludedBlockID ||
            getBlockId(texcoord + vec2(1.0, 0.0) * texelsize) == excludedBlockID ||
            getBlockId(texcoord + vec2(1.0, 1.0) * texelsize) == excludedBlockID) {
                exclusionFilter = 0.0;
            }
    #endif

    float d_middle = linearizeDepth(texture(depthtex0, texcoord).r);
    if (d_middle > EDGE_DETECTION_STRENGTH) {
        return color;
    }

    float d_topleft = linearizeDepth(texture(depthtex0, texcoord + vec2(-1.0, 1.0) * texelsize).r);
    float d_left = linearizeDepth(texture(depthtex0, texcoord + vec2(-1.0, 0.0) * texelsize).r);
    float d_bottomleft = linearizeDepth(texture(depthtex0, texcoord + vec2(-1.0, -1.0) * texelsize).r);
    float d_top = linearizeDepth(texture(depthtex0, texcoord + vec2(0.0, 1.0) * texelsize).r);
    float d_bottom = linearizeDepth(texture(depthtex0, texcoord + vec2(0.0, -1.0) * texelsize).r);
    float d_topright = linearizeDepth(texture(depthtex0, texcoord + vec2(1.0, 1.0) * texelsize).r);
    float d_right = linearizeDepth(texture(depthtex0, texcoord + vec2(1.0, 0.0) * texelsize).r);
    float d_bottomright = linearizeDepth(texture(depthtex0, texcoord + vec2(1.0, -1.0) * texelsize).r);

    float d_horizontalgradient = -d_topleft + d_topright - (2.0 * d_left) + (2.0 * d_right) - d_bottomleft + d_bottomright;
    float d_verticalgradient = d_topleft + (2.0 * d_top) + d_topright - d_bottomleft - (2.0 * d_bottom) - d_bottomright;
    float depthMag = sqrt((d_horizontalgradient * d_horizontalgradient) + (d_verticalgradient * d_verticalgradient));

    depthMag /= max(d_middle, 0.001);

    vec3 n_topleft = texture(colortex2, texcoord + vec2(-1.0, 1.0) * texelsize).xyz;
    vec3 n_left = texture(colortex2, texcoord + vec2(-1.0, 0.0) * texelsize).xyz;
    vec3 n_bottomleft = texture(colortex2, texcoord + vec2(-1.0, -1.0) * texelsize).xyz;
    vec3 n_top = texture(colortex2, texcoord + vec2(0.0, 1.0) * texelsize).xyz;
    vec3 n_middle = texture(colortex2, texcoord).xyz;
    vec3 n_bottom = texture(colortex2, texcoord + vec2(0.0, -1.0) * texelsize).xyz;
    vec3 n_topright = texture(colortex2, texcoord + vec2(1.0, 1.0) * texelsize).xyz;
    vec3 n_right = texture(colortex2, texcoord + vec2(1.0, 0.0) * texelsize).xyz;
    vec3 n_bottomright = texture(colortex2, texcoord + vec2(1.0, -1.0) * texelsize).xyz;

    vec3 n_horizontalgradient = -n_topleft + n_topright - (2.0 * n_left) + (2.0 * n_right) - n_bottomleft + n_bottomright;
    vec3 n_verticalgradient = n_topleft + (2.0 * n_top) + n_topright - n_bottomleft - (2.0 * n_bottom) - n_bottomright;
    float normalMag = sqrt(dot(n_horizontalgradient, n_horizontalgradient) + dot(n_verticalgradient, n_verticalgradient));

    float finalGradient = depthMag * 0.5 + normalMag * 2.0;

    #if EXCLUDE_FOLIAGE == 1
        finalGradient *= exclusionFilter;
    #endif

    if (finalGradient > 0.22) {
        return color.rgb * EDGE_BRIGHTNESS;
    }
    
    return color;
}