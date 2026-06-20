#include "/lib/definitions.glsl"
#include "/lib/distort.glsl"

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homePos = projectionMatrix * vec4(position, 1.0);
	return homePos.xyz / homePos.w;
}

vec3 applyFog(vec3 color, vec2 texcoord, sampler2D depthtex0, float far, vec3 fogColor, mat4 gbufferModelViewInverse, mat4 gbufferProjectionInverse) {
    #if FOG_ON == 1
        float depth = texture(depthtex0, texcoord).r;
        if (depth == 1.0) {
            return color;
        }

        vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
        vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

        float dist = length(viewPos) / far;
        float fogFactor = exp(-FOG_DENSITY * (1.0 - dist));

        return mix(color, pow(fogColor, vec3(2.2)), clamp(fogFactor, 0.0, 1.0));
    #endif
    return color;
}