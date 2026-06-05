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

#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex2; // normal data from terrain gbuffer
uniform sampler2D depthtex0;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;

#define EDGE_DETECTION //Toggle for edge detection

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

float linearizeDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

void main() {
    vec2 texelsize = vec2(1.0 / viewWidth, 1.0 / viewHeight) * 2.0;
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

    float edgeFactor = smoothstep(0.3, 0.7, gradientmagnitude);

    vec3 baseColor = texture(colortex0, texcoord).rgb;
    vec3 outlineColor = mix(baseColor, vec3(1.0), 0.5);
    float outlineAlpha = 0.6;
    float edgeBrightness = 3.5;

    // todo:
    // - leaf block holes are exempt
    // - make it smoother
    // - color it according to the block colors

    if (linearizeDepth(texture(depthtex0, texcoord).r) > 0.5) {
        color.rgb = texture(colortex0, texcoord).rgb;
        return;
    }

    if (gradientmagnitude > 0.01) {
        #ifdef EDGE_DETECTION
            //below is the og one
            //color.rgb = mix(baseColor, outlineColor, edgeFactor * outlineAlpha);
            color.rgb = baseColor.rgb * edgeBrightness;
        #else
            color.rgb = texture(colortex0, texcoord).rgb;
        #endif
    } else {
        color.rgb = texture(colortex0, texcoord).rgb;
    }
}