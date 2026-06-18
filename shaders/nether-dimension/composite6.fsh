#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

#include "/lib/definitions.glsl"
#include "/lib/effects/chromatic_aberration.glsl"

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

void main() {
    color = applyAberration(1, colortex0, texcoord);
}