#version 330 compatibility

/*
const int colortex4Format=R16F;
*/

uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
flat in int vBlockID;

/* RENDERTARGETS: 0,1,2,4 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 idData;

void main() {
	vec4 baseColor = texture(gtexture, texcoord);

	float maxColorChan = max(glcolor.r, max(glcolor.g, glcolor.b));
	vec4 cleanTint = vec4(1.0);
	if (maxColorChan > 0.0) {
		cleanTint.rgb = glcolor.rgb / maxColorChan;
	}
	cleanTint.a = glcolor.a;

	color = baseColor * cleanTint;
	idData = vec4(float(vBlockID), 0.0, 0.0, 1.0);

	if (color.a < alphaTestRef) {
		discard;
	}

	lightmapData = vec4(lmcoord, 0.0, 1.0);
	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
}