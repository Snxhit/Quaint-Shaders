#version 330 compatibility

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

#include "/lib/definitions.glsl"
#include "/lib/effects/tonemapping.glsl"

void main() {
    color.rgb = applyToneMapping(1, colortex0, texcoord);
}