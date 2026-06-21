#version 330 compatibility

uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
flat out int vBlockID;

in vec2 mc_Entity;

#include "/lib/definitions.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0);
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;
	normal = mat3(gbufferModelViewInverse) * normal;
	vBlockID = int(mc_Entity.x);

	#if WAVING_FOLIAGE == 1
		vec4 position = gl_Vertex;
		if (int(mc_Entity.x) == 3) {
			float timeScale = frameTimeCounter * 0.8;
			float wave = sin(timeScale + position.x * 0.5) * cos(timeScale * 0.5 + position.z * 0.5);
			float swayStrength = 0.04;
			position.x += wave * swayStrength;
			position.z += wave * swayStrength;
		}

		gl_Position = gl_ModelViewProjectionMatrix * position;
	#else
		gl_Position = ftransform();
	#endif
}