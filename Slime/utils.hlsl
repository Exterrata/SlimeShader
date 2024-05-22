#if !UTILS_INCLUDED
#define UTILS_INCLUDED

#define EPSILON 0.000000001
#define PI2 6.28318530718

//#if STEREO_MULTIVIEW_ON
#if STEREO_INSTANCING_ON
    #define SAMPLE_SCREEN_TEX(tex, texCoords) tex[int3(texCoords, unity_StereoEyeIndex)]
    #define DECLARE_SCREEN_TEX(tex) Texture2DArray tex
#else
    #define SAMPLE_SCREEN_TEX(tex, texCoords) tex[texCoords]
    #define DECLARE_SCREEN_TEX(tex) Texture2D tex
#endif

float AdjustStereoScreenPos(float x) {
#if defined(UNITY_SINGLE_PASS_STEREO)
    return (unity_StereoEyeIndex * _ScreenParams.x) + x;
#else
    return x;
#endif
}
    
float2 ClampStereoScreenPos(float2 uv) {
#if defined(UNITY_SINGLE_PASS_STEREO)
    float2 shift = float2(unity_StereoEyeIndex * _ScreenParams.x, 0);
    return clamp(uv - shift, 0, _ScreenParams.xy) + shift;
#else
    return clamp(uv, 0, _ScreenParams.xy);
#endif
}

//from https://bottosson.github.io/posts/oklab/
float3 RGBToOKLAB(float3 c) {
    const float3x3 m1 = float3x3(
        0.4122214708, 0.5363325363, 0.0514459929,
	    0.2119034982, 0.6806995451, 0.1073969566,
	    0.0883024619, 0.2817188376, 0.6299787005
    );
    const float3x3 m2 = float3x3(
        0.2104542553, 0.7936177850, -0.0040720468,
        1.9779984951, -2.4285922050, 0.4505937099,
        0.0259040371, 0.7827717662, -0.8086757660
    );
    c = mul(m1, c);
    c = pow(c, 0.333333333333333);
    c = mul(m2, c);
    return c;
}

float3 OKLABToRGB(float3 c) {
    const float3x3 m1 = float3x3(
        1, 0.3963377774, 0.2158037573,
        1, -0.1055613458, -0.0638541728,
        1, -0.0894841775, -1.2914855480
    );
    const float3x3 m2 = float3x3(
		4.0767416621, -3.3077115913, 0.2309699292,
		-1.2684380046, 2.6097574011, -0.3413193965,
		-0.0041960863, -0.7034186147, 1.7076147010
    );
    c = mul(m1, c);
    c = pow(c, 3);
    c = mul(m2, c);
    return c;
}

float3 SampleEnviroment(float3 position, float3 direction) {
	float3 factors = ((direction > 0 ? unity_SpecCube0_BoxMax.xyz : unity_SpecCube0_BoxMin.xyz) - position) / direction;
	float scalar = min(min(factors.x, factors.y), factors.z);
	return direction * scalar + (position - unity_SpecCube0_ProbePosition);
}

#endif