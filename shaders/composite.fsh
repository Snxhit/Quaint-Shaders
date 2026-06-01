#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);
	if (texcoord.x > 0.5) {
		float gscale = dot(color.rgb, vec3(1.0/3.0));
		color.rgb = vec3(gscale);
	} else {
		float gscale = dot(color.rgb, vec3(2.0/3.0));
		color.rgb = vec3(gscale);
	}
}