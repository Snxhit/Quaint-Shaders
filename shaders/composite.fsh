#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform float viewWidth;
uniform float viewHeight;
// TODO: Vary lighting according to daynight cycle
uniform int dayTime;

#define SHADOW_RADIUS 2
#define SHADOW_RANGE 4

#include "/lib/distort.glsl"

in vec2 texcoord;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homePos = projectionMatrix * vec4(position, 1.0);
	return homePos.xyz / homePos.w;
}

vec3 getShadow(vec3 shadowScreenPos) {
	float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);
	if (transparentShadow == 1.0) {
		return vec3(1.0);
	}

	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);

	if (opaqueShadow == 0.0) {
		return vec3(0.0);
	}

	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);

	return shadowColor.rgb * (1.0 - shadowColor.a);
}

vec4 getNoise(vec2 coord) {
	ivec2 screenCoord = ivec2(coord * vec2(viewWidth, viewHeight));
	ivec2 noiseCoord = screenCoord % 64;
	return texelFetch(noisetex, noiseCoord, 0);
}

vec3 getSoftShadow(vec4 shadowClipPos) {
	vec3 shadowAccum = vec3(0.0);
	const int samples = SHADOW_RANGE * SHADOW_RANGE * 4;
	float noise = getNoise(texcoord).r;

	float theta = noise * radians(360.0);
	float cosTheta = cos(theta);
	float sinTheta = sin(theta);
	
	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

	for (int x = -SHADOW_RANGE; x < SHADOW_RANGE; x++) {
		for (int y = -SHADOW_RANGE; y < SHADOW_RANGE; y++) {
			vec2 offset = vec2(x, y) * SHADOW_RADIUS / float(SHADOW_RANGE);
			offset = rotation * offset;
			offset /= shadowMapResolution;
			vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0.0, 0.0);
			offsetShadowClipPos.z -= 0.001;
			offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
			vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
			vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
			shadowAccum += getShadow(shadowScreenPos);
		}
	}

	return shadowAccum / float(samples);
}

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);
	vec2 lightmap = texture(colortex1, texcoord).rg;
	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
	const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
	const vec3 sunlightColor = vec3(1.0);
	const vec3 ambientColor = vec3(0.1);

	vec3 blocklight = lightmap.r * blocklightColor;
	vec3 skylight = lightmap.g * skylightColor;
	vec3 ambient = ambientColor;
	//vec3 sunlight = sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * lightmap.g;

	float depth = texture(depthtex0, texcoord).r;
	if (depth == 1.0) {
		return;
	}

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);

	vec3 shadow = getSoftShadow(shadowClipPos);
	vec3 sunlight = sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * shadow;

	color.rgb *= blocklight + skylight + ambient + sunlight;
	color.rgb = pow(color.rgb, vec3(2.2));
}