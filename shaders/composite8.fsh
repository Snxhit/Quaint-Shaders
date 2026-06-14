#version 330 compatibility

uniform sampler2D colortex0;
uniform float viewHeight;
uniform float viewWidth;

#include "/lib/definitions.glsl"

in vec2 texcoord;

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

float getLuma(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

void main() {
    vec2 texelSize = vec2(1.0 / viewWidth, 1.0 / viewHeight);

    vec3 oColor = texture(colortex0, texcoord).rgb;
    float oLuma = getLuma(oColor);

    float lumaN = getLuma(texture(colortex0, texcoord + vec2(0.0, texelSize.y)).rgb);
    float lumaS = getLuma(texture(colortex0, texcoord + vec2(0.0, -texelSize.y)).rgb);
    float lumaW = getLuma(texture(colortex0, texcoord + vec2(texelSize.x, 0.0)).rgb);
    float lumaE = getLuma(texture(colortex0, texcoord + vec2(-texelSize.x, 0.0)).rgb);

    float lumaMin = min(oLuma, min(min(lumaN, lumaS), min(lumaE, lumaW)));
    float lumaMax = max(oLuma, max(max(lumaN, lumaS), max(lumaE, lumaW)));
    float lumaRange = lumaMax - lumaMin;

    if (lumaRange < max(FXAA_MIN_THRESHOLD, lumaMax * FXAA_MAX_THRESHOLD)) {
        color.rgb = texture(colortex0, texcoord).rgb;
        return;
    }

    float lumaNW = getLuma(texture(colortex0, texcoord + vec2(-texelSize.x, texelSize.y)).rgb);
    float lumaNE = getLuma(texture(colortex0, texcoord + vec2(texelSize.x, texelSize.y)).rgb);
    float lumaSW = getLuma(texture(colortex0, texcoord + vec2(-texelSize.x, -texelSize.y)).rgb);
    float lumaSE = getLuma(texture(colortex0, texcoord + vec2(texelSize.x, -texelSize.y)).rgb);

    float edgeHorizontal = abs((lumaNW + lumaNE) - 2.0 * lumaN) * 2.0 + abs((lumaW + lumaE) - 2.0 * oLuma) * 2.0 + abs((lumaSW + lumaSE) - 2.0 * lumaS);
    float edgeVertical = abs((lumaNW + lumaSW) - 2.0 * lumaW) * 2.0 + abs((lumaN + lumaS) - 2.0 * oLuma) * 2.0 + abs((lumaNE + lumaSE) - 2.0 * lumaE);

    bool isHorizontal = (edgeHorizontal >= edgeVertical);

    float stepLength = isHorizontal ? texelSize.y : texelSize.x;
    float luma1 = isHorizontal ? lumaN : lumaW;
    float luma2 = isHorizontal ? lumaS : lumaE;

    float gradient1 = abs(luma1 - oLuma);
    float gradient2 = abs(luma2 - oLuma);

    if (gradient1 < gradient2) {
        stepLength = -stepLength;
    }

    float lumaAvg = (2.0 * (lumaN + lumaS + lumaE + lumaW) + (lumaNW + lumaNE + lumaSW + lumaSE)) / 12.0;
    float subPixelBlend = clamp(abs(lumaAvg - oLuma) / lumaRange, 0.0, 1.0);
    subPixelBlend = smoothstep(0.0, 1.0, subPixelBlend);
    subPixelBlend = subPixelBlend * subPixelBlend * SUBPIXEL_QUALITY;

    vec2 edgeCoord = texcoord;
    if (isHorizontal) {
        edgeCoord.y += stepLength * 0.5;
    } else {
        edgeCoord.x += stepLength * 0.5;
    }

    vec2 edgeStep = isHorizontal ? vec2(texelSize.x, 0.0) : vec2(0.0, texelSize.y);
    vec2 coordPos = edgeCoord + edgeStep;
    vec2 coordNeg = edgeCoord - edgeStep;

    float lumaEdgeTarget = (gradient1 >= gradient2) ? luma1 : luma2;
    lumaEdgeTarget = (lumaEdgeTarget + oLuma) * 0.5;
    float edgeThreshold = max(gradient1, gradient2) * 0.25;

    float distancePos = 0.0;
    float distanceNeg = 0.0;

    for (int i = 0; i < FXAA_ITERATIONS; i++) {
        float lumaPosSample = getLuma(texture(colortex0, coordPos).rgb);
        if (abs(lumaPosSample - lumaEdgeTarget) > edgeThreshold) {
            distancePos = float(i) + 1.0;
            break;
        }
        coordPos += edgeStep;
    }

    for (int i = 0; i < FXAA_ITERATIONS; i++){
        float lumaNegSample = getLuma(texture(colortex0, coordNeg).rgb);
        if (abs(lumaNegSample - lumaEdgeTarget) > edgeThreshold) {
            distanceNeg = float(i) + 1.0;
            break;
        }
        coordNeg -= edgeStep;
    }

    float totalDist = distancePos + distanceNeg;
    float pixelOffset = (totalDist > 0.0) ? (0.5 - (min(distancePos, distanceNeg) / totalDist)) : 0.0;

    float finalOffset = max(subPixelBlend, pixelOffset);

    vec2 finalPos = texcoord;
    if (isHorizontal) {
        finalPos.y += stepLength * finalOffset;
    } else {
        finalPos.x += stepLength * finalOffset;
    }

    color.rgb = texture(colortex0, finalPos).rgb;
}