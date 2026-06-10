#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform float frameTimeCounter;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

void main() {
	vec2 animatedTexcoord = texcoord;
	animatedTexcoord.x += sin(frameTimeCounter * 0.8 + texcoord.y * 10.0) * 0.01;
	animatedTexcoord.y += cos(frameTimeCounter * 0.6 + texcoord.x * 10.0) * 0.01;

	color = texture(gtexture, texcoord) * glcolor;
	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}
	
	lightmapData = vec4(lmcoord, 0.0, 1.0);
	encodedNormal = vec4(0.5, 0.5, 1.0, 1.0);
}