#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

#include "/lib/definitions.glsl"
#include "/lib/effects/SSAO.glsl"

void main() {
	#if SSAO_ENABLED == 1
		color = applySSAO(colortex0, texcoord, depthtex0, gbufferProjectionInverse, gbufferProjection);
	#else
		color = texture(colortex0, texcoord).rgb;
	#endif
}