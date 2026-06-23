#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex2; // normal data from terrain gbuffer
uniform sampler2D colortex4; // block id data
uniform sampler2D colortex5; // entity data
uniform sampler2D depthtex0;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;

#include "/lib/definitions.glsl"
#include "/lib/effects/edge_detection.glsl"
#include "/lib/effects/bloom.glsl"
#include "/lib/effects/fog.glsl"

in vec2 texcoord;
const int excludedBlockID = 3;

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

void main() {
    color.rgb = applySinglePassBloom(colortex0, texcoord, viewWidth, viewHeight).rgb;
    color.a = 1;
    color.rgb = edgeDetect(1, color.rgb, colortex2, colortex5, depthtex0, texcoord, viewWidth, viewHeight, excludedBlockID);
	color.rgb = applyFog(color.rgb, texcoord, depthtex0, far, fogColor, gbufferModelViewInverse, gbufferProjectionInverse);
}