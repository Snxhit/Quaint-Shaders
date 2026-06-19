#version 330 compatibility

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

#include "/lib/definitions.glsl"
#include "/lib/effects/bloom.glsl"

in vec2 texcoord;

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

void main() {
    color.rgb = texture(colortex0, texcoord).rgb;
}