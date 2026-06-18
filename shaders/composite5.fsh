#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

// ts file procedurally applies vibrancy
    // need to make shadows more normal

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 color;

#include "/lib/definitions.glsl"
#include "/lib/effects/tonemapping.glsl"

void main() {
    color.rgb = applyToneMapping(0, colortex0, texcoord);
}