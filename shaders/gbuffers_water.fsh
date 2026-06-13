#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform float frameTimeCounter;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 worldPos;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

float getWaterWaves(vec2 pos) {
	float time = frameTimeCounter * 1.2;

	float w1 = sin(pos.x * 0.5 + time) * cos(pos.y * 0.5 - time * 0.6);
	float w2 = sin(pos.y * 1.2 + time * 1.5) * cos(pos.x * 0.8 + time * 1.1);
	float w3 = sin((pos.x + pos.y) * 3.0 - time * 2.0) * 0.5;

	return (w1 + w2 + w3) * 0.15;
}

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	if (color.a < alphaTestRef) {
		discard;
	}

	float delta = 0.1;
	float hL = getWaterWaves(worldPos.xz - vec2(delta, 0.0));
	float hR = getWaterWaves(worldPos.xz + vec2(delta, 0.0));
	float hD = getWaterWaves(worldPos.xz - vec2(0.0, delta));
	float hU = getWaterWaves(worldPos.xz + vec2(0.0, delta));

	vec3 waveNormal = normalize(vec3(hL - hR, delta * 2.0, hD - hU));

	vec3 normalOut = waveNormal * 0.5 + 0.5;

	color *= texture(lightmap, lmcoord);

	lightmapData = vec4(lmcoord, 0.0, 1.0);
	encodedNormal = vec4(normalOut, 1.0);
}