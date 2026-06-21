#version 330 compatibility

uniform float frameTimeCounter;

in vec4 mc_Entity;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 worldPos;

#include "/lib/definitions.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec4 position = gl_Vertex;

	worldPos = position.xyz;

	#if WAVING_WATER == 1
		int blockId = int(mc_Entity.x + 0.1);

		if (blockId == 2) {
			float time = frameTimeCounter * 1.5;

			float wave1 = sin(time + position.x * 0.8 + position.z * 0.4) * 0.04;
			float wave2 = cos(time * 0.7 + position.x * 0.3 + position.z * 0.9) * 0.03;

			position.y += wave1 + wave2;
		}

		gl_Position = gl_ModelViewProjectionMatrix * position;
	#else
		gl_Position = ftransform();
	#endif
}