#version 330 compatibility

uniform float frameTimeCounter;

in vec4 mc_Entity;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec4 position = gl_Vertex;

	int blockId = int(mc_Entity.x + 0.1);

	if (blockId == 2) {
		float waveSpeed = frameTimeCounter * 2.5;
		float waveScaleX = position.x * 1.5;
		float waveScaleZ = position.z * 1.5;

		float waveY = sin(waveSpeed + waveScaleX) * 0.08 + cos(waveSpeed * 0.5 + waveScaleZ) * 0.05;

		float waveX = sin(waveSpeed * 0.3 + waveScaleZ) * 0.03;

		position.y += waveY;
		position.x += waveX;
	}

	gl_Position = gl_ModelViewProjectionMatrix * position;
}