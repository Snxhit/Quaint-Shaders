// custom lighting & shadows
#define SHADOWS 1 // [0 1]
#define SHADOW_RADIUS 2 // [1 2 3 4]
#define SHADOW_RANGE 4 // [3 4 5]

// fog
#define FOG_ON 1 // [0 1]
#define FOG_DENSITY 5.0 // [5.0]

// edge detection
#define EDGE_DETECTION 1 // [0 1]
#define EDGE_DETECTION_MODE 0 // [0 1]
#define EDGE_DETECTION_STRENGTH 0.6 // [0.3 0.4 0.5 0.6 0.7]
#define EDGE_SIZE 2.0 // [1.0 2.0 3.0]
#define EDGE_BRIGHTNESS 3.5 // [1.5 2.0 2.5 3.0 3.5 4.0]
#define EXCLUDE_ENTITIES 1 // [0 1]
#define EXCLUDE_FOLIAGE 1 // [0 1]

// bloom (applies to the whole screen)
#define BLOOM_ON 1 // [0 1]
#define BLOOM_THRESHOLD 0.9 // [0.3 0.5 0.7 0.9]

// chromatic aberration
#define CHROMATIC_ABERRATION 1 // [0 1]
#define CHROMATIC_ABERRATION_STRENGTH 0.05 // [0.01 0.025 0.05 0.1]

// ACES tone mapping
#define COLOR_MAPPING 1 // [0 1]

// FXAA (fast approximate anti-aliasinf)
#define FXAA_ENABLED 1 // [0 1]
#define FXAA_MIN_THRESHOLD 0.0312
#define FXAA_MAX_THRESHOLD 0.125
#define FXAA_ITERATIONS 8
#define SUBPIXEL_QUALITY 0.75

// SSAO (screen space ambient occlusion)
#define SSAO_ENABLED 1 // [0 1]
#define SSAO_SAMPLES 16 // [8 16 24 32 48 64]
#define SSAO_RADIUS 0.45 // [0.15 0.25 0.45 0.75 1.0 1.5]
#define SSAO_POWER 2.0 // [0.5 1.0 1.5 2.0 3.0 4.0]
#define SSAO_BIAS 0.03 // [0.01 0.02 0.03 0.05 0.1]
#define SSAO_BLUR_SHARPNESS 200.0 // [100.0 200.0 300.0]

// environment
#define WAVING_WATER 1 // [0 1]
#define WAVING_FOLIAGE 1 // [0 1]