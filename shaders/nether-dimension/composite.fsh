#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	#if CUSTOM_LIGHTING == 1
		color = texture(colortex0, texcoord);
		vec2 lightmap = texture(colortex1, texcoord).rg;
		vec3 encodedNormal = texture(colortex2, texcoord).rgb;
		vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

		vec3 worldLightVector = vec3(0.0, 1.0, 0.0);

		const vec3 blocklightColor = vec3(0.2, 0.4, 0.1);
		const vec3 netherAmbientColor = vec3(0.01, 0.005, 0.005);

		vec3 blocklight = lightmap.r * blocklightColor;
		vec3 ambient = netherAmbientColor;

		float directionalShading = clamp(dot(worldLightVector, normal), 0.0, 1.0);
		vec3 netherGlow = vec3(0.15) * directionalShading;

		color.rgb *= blocklight + ambient + netherGlow;
		color.rgb = pow(color.rgb, vec3(2.2));
	#else
		color.rgb = texture(colortex0, texcoord).rgb;
	#endif
}