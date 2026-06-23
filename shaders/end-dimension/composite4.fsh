#version 330 compatibility

uniform sampler2D colortex0;
uniform float viewHeight;
uniform float viewWidth;

#include "/lib/definitions.glsl"
#include "/lib/effects/FXAA.glsl"

in vec2 texcoord;

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

void main() {
    color.rgb = applyFXAA(colortex0, texcoord, viewWidth, viewHeight);
}