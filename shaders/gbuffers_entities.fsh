#version 330 compatibility

uniform sampler2D gtexture;
uniform vec4 entityColor; // Passes the hurt (red) or exploding creeper (white) overlay
uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

void main() {
	// 1. Sample texture and apply standard vertex vertex coloring
	color = texture(gtexture, texcoord) * glcolor;
	
	// 2. Mix the base color with the hurt flash color safely BEFORE checking transparency
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	
	if (color.a < alphaTestRef) {
		discard;
	}

	// 3. Write data to layout 1 so the post-processor can apply lighting & vibrancy
	lightmapData = vec4(lmcoord, 0.0, 1.0);
	
	// 4. Pass a flat placeholder normal vector to prevent rendering glitches
	encodedNormal = vec4(0.5, 0.5, 1.0, 1.0);
}
