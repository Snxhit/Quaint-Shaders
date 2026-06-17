#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex2; // normal data from terrain gbuffer
uniform sampler2D colortex4; // block id data
uniform sampler2D depthtex0;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;

#include "/lib/definitions.glsl"
#include "/lib/effects/edge_detection.glsl"

in vec2 texcoord;
const int excludedBlockID = 3;

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

void main() {
    float sampledId = texture(colortex4, texcoord).x;
    int blockId = int(sampledId + 0.5);

    if (sampledId < -0.5) {
        blockId = -1;
    }

    #if EDGE_DETECTION == 1
        color.rgb = edgeDetect(0, colortex0, colortex2, depthtex0, texcoord, viewWidth, viewHeight, excludedBlockID);
    #else
        color.rgb = texture(colortex0, texcoord).rgb;
    #endif
}