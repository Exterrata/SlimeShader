#if !SLIME_INCLUDED
#define SLIME_INCLUDED
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fog
#pragma target 5.0
#include "AutoLight.cginc"
#include "Lighting.cginc"
#include "core.hlsl"
#include "utils.hlsl"

#pragma skip_variants LIGHTMAP_ON DYNAMICLIGHTMAP_ON LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK DIRLIGHTMAP_COMBINED
#pragma shader_feature_local _ENABLE_LCH1_ON
#pragma shader_feature_local _ENABLE_LCH2_ON
#pragma shader_feature_local _ENABLE_NORMAL1_ON
#pragma shader_feature_local _ENABLE_NORMAL2_ON
#pragma shader_feature_local _ENABLE_HEIGHT_ON
#pragma shader_feature_local _ENABLE_BLUR_ON
#pragma shader_feature_local _ENABLE_REFLECTION_ON
#pragma shader_feature_local _ENABLE_RIMLIGHT_ON
#pragma shader_feature_local _ENABLE_EMISSION_ON
#pragma shader_feature_local _ENABLE_MATCAP_ON
#pragma shader_feature_local _ENABLE_BULGE_ON

sampler2D _SlimeMask;
sampler2D _SlimeTex;
sampler2D _MainTex;
sampler2D _BumpMap1;
sampler2D _BumpMap2;
sampler2D _HeightMap;
sampler2D _LCHMask1;
sampler2D _LCHMask2;
sampler2D _Emission;
sampler2D _MatCap1;
sampler2D _MatCap2;
DECLARE_SCREEN_TEX(_SlimeGrab);
DECLARE_SCREEN_TEX(_CameraDepthTexture);
float4 _SlimeColor;
float4 _MainColor;
float4 _MatCapCol1;
float4 _MatCapCol2;
float4 _BumpMap1_ST;
float4 _BumpMap2_ST;
float3 _LCH1;
float3 _LCH2;
float _Invert_LCH1;
float _Invert_LCH2;
float _BumpPow;
float _HeightScale;
float _HeightPow;
float _MatCapBlur1;
float _MatCapBlur2;
float _Index;
float _Bulge;
float _BulgeDist;
float _Metallic;
float _Smoothness;
float _Reflectivity;
float _RimPow;
float _MinLighting;
float _MaxLighting;
float _Monochrome;
float _Blend;
float _DepthBlend;
float _ColorBlend;

struct appdata {
    float4 vertex : POSITION;
    #if _ENABLE_NORMAL1_ON || _ENABLE_NORMAL2_ON || _ENABLE_HEIGHT_ON || _ENABLE_MATCAP_ON
        float4 tangent : TANGENT;
    #endif
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f {
    float4 pos : SV_POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
    float3 viewDir : TEXCOORD2;
    float3 lightDirection : TEXCOORD3;
    float3 indirectLight : TEXCOORD4;
    float3 directLight : TEXCOORD5;
    UNITY_FOG_COORDS(6)
    UNITY_LIGHTING_COORDS(7, 8)
    float3 binormal : TEXCOORD9;
    float3 tangent : TEXCOORD10;
    float2 tangentViewDir : TEXCOORD11;
    float3 vertexLight : TEXCOORD12;
    UNITY_VERTEX_OUTPUT_STEREO
};

fixed3 GrabBluredTexure(float2 uv, float2 uv2, float dist) {
    int2 limit = _ScreenParams.xy - 1;
    float2 s = normalize(uv - uv2) * pow(dist, 0.5f);
    fixed3 col = SAMPLE_SCREEN_TEX(_SlimeGrab, int2(uv)).rgb * 0.08405720206670768;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s)).rgb * 0.0836379260498925;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 2)).rgb * 0.08239370064716366;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 3)).rgb * 0.080361193601741752;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 4)).rgb * 0.038799785395608;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 5)).rgb * 0.077599570791216;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 6)).rgb * 0.070220843113003472;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 7)).rgb * 0.06580517234639484;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 8)).rgb * 0.06105407815331736;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 9)).rgb * 0.05608285535109634;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 10)).rgb * 0.051004256378591544;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 11)).rgb * 0.045924411803294506;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 12)).rgb * 0.040939414851981492;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 13)).rgb * 0.036132702019991136;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 14)).rgb * 0.031573297750108976;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 15)).rgb * 0.027314928081965604;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 16)).rgb * 0.023395951308656668;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 17)).rgb * 0.01984000714529696;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 18)).rgb * 0.01665725238166177;
    col += SAMPLE_SCREEN_TEX(_SlimeGrab, ClampStereoScreenPos(uv + s * 19)).rgb * 0.01384603158711488;
    return col;
}

fixed4 raymarch(float3 ro, float3 rd) {
    float4 start = UnityWorldToClipPos(ro);
    start = ComputeNonStereoScreenPos(start);
    start.xyz = (start.xyz / start.w) * float3(_ScreenParams.xy, 1);

    float4 end = UnityWorldToClipPos(ro + rd);
    end = ComputeNonStereoScreenPos(end);
    end.xyz = (end.xyz / end.w) * float3(_ScreenParams.xy, 1);

    float3 delta = end.xyz - start.xyz;
    start.x = AdjustStereoScreenPos(start.x);
    float3 currentPos = start.xyz;

    float step = max(abs(delta.x), abs(delta.y));
    int steps = min(64, step);
    delta.xyz /= step;
    int i = 0;
    [loop]
    for (; i < steps; i++) {
        float depth1 = SAMPLE_SCREEN_TEX(_CameraDepthTexture, currentPos.xy).r;
        float depth2 = SAMPLE_SCREEN_TEX(_CameraDepthTexture, currentPos.xy + delta.xy).r;
        float depth3 = SAMPLE_SCREEN_TEX(_CameraDepthTexture, currentPos.xy + delta.xy * 2).r;
        float depth4 = SAMPLE_SCREEN_TEX(_CameraDepthTexture, currentPos.xy + delta.xy * 3).r;

        if (depth1 > currentPos.z) break;
        currentPos += delta;
        if (depth2 > currentPos.z) break;
        currentPos += delta;
        if (depth3 > currentPos.z) break;
        currentPos += delta;
        if (depth4 > currentPos.z) break;
    }

    float2 uv = ClampStereoScreenPos(currentPos.xy);
    precise float dist = saturate(length(delta * i) / length(delta * steps));
    #if _ENABLE_BLUR_ON
        return float4(GrabBluredTexure(uv - delta.xy, uv, dist), 1 - dist);
    #else
        return float4(SAMPLE_SCREEN_TEX(_SlimeGrab, uv - delta.xy).rgb, 1 - dist);
    #endif
}

v2f vert (appdata v) {
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(v2f, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    #if _ENABLE_NORMAL1_ON || _ENABLE_NORMAL2_ON || _ENABLE_HEIGHT_ON || _ENABLE_MATCAP_ON
        float3 binormal = cross(v.normal, v.tangent.xyz) * (v.tangent.w * unity_WorldTransformParams.w);
    #endif
    #if _ENABLE_NORMAL1_ON || _ENABLE_NORMAL2_ON || _ENABLE_MATCAP_ON
        o.tangent = UnityObjectToWorldDir(v.tangent);
        o.binormal = UnityObjectToWorldDir(binormal);
    #endif
    #if _ENABLE_HEIGHT_ON
        float3x3 ObjectToTangent = float3x3(v.tangent.xyz, binormal, v.normal);
        o.tangentViewDir = mul(ObjectToTangent, normalize(-ObjSpaceViewDir(v.vertex))).xy;
    #endif

    o.uv = v.uv;
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.pos = UnityObjectToClipPos(v.vertex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    o.viewDir = normalize(o.worldPos - _WorldSpaceCameraPos);

    #if _ENABLE_BULGE_ON
    float4 grab = ComputeGrabScreenPos(o.pos);
    grab.xyz /= grab.w;
    float bulge = (1 - saturate(abs(LinearEyeDepth(grab.z) - LinearEyeDepth(SAMPLE_SCREEN_TEX(_CameraDepthTexture, grab.xy * _ScreenParams.xy)) / _BulgeDist))) * _BulgeDist;
    v.vertex.xyz += v.normal.xyz * _Bulge * bulge;
    o.pos = UnityObjectToClipPos(v.vertex);
    #endif

    #if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH && defined(VERTEXLIGHT_ON)
        o.vertexLight = min(ComputeAdditionalLights(o.worldPos, o.pos), _MaxLighting);
    #endif
    #if defined(FORWARD_BASE)
        ComputeLights(o.lightDirection, o.directLight, o.indirectLight);
        o.indirectLight = clamp(o.indirectLight, 0.0, _MaxLighting);
        o.directLight = clamp(o.directLight, _MinLighting, _MaxLighting);
        o.directLight = lerp(o.directLight, OpenLitGray(o.directLight), _Monochrome);
    #endif
    
    UNITY_TRANSFER_FOG(o,o.pos);
    UNITY_TRANSFER_LIGHTING(o,v.uv);
    return o;
}

fixed3 frag (v2f i) : SV_Target {
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
    //-------------------------------------------------height map-------------------------------------------------
    #if _ENABLE_HEIGHT_ON
        float height = tex2D(_HeightMap, i.uv * _HeightScale).r;
        i.uv += i.tangentViewDir * height * _HeightPow;
    #endif
    //-------------------------------------------------normal map-------------------------------------------------
    float3 normal;
    #if _ENABLE_NORMAL1_ON
        normal = UnpackScaleNormal(tex2D(_BumpMap1, i.uv * _BumpMap1_ST.xy + (_BumpMap1_ST.zw * _Time.x)), _BumpPow);
        i.normal = normalize(normal.x * i.tangent + normal.y * i.binormal + normal.z * i.normal);
    #endif
    #if _ENABLE_NORMAL2_ON
        normal = UnpackScaleNormal(tex2D(_BumpMap2, i.uv * _BumpMap2_ST.xy + (_BumpMap2_ST.zw * _Time.x)), _BumpPow);
        i.normal = normalize(normal.x * i.tangent + normal.y * i.binormal + normal.z * i.normal);
    #endif
    #if !_ENABLE_NORMAL1_ON && !_ENABLE_NORMAL2_ON
        i.normal = normalize(i.normal);
    #endif
    //-------------------------------------------------base color-------------------------------------------------
    float mask = tex2D(_SlimeMask, i.uv).r;
    fixed3 col = tex2D(_MainTex, i.uv).rgb * _MainColor;
    fixed3 slimeCol = tex2D(_SlimeTex, i.uv) * _SlimeColor.rgb;
    col = lerp(col, slimeCol, mask);
    float LCHmask;
    #if _ENABLE_LCH1_ON
        LCHmask = tex2D(_LCHMask1, i.uv).r;
        if (_Invert_LCH1 > 0) LCHmask = 1 - LCHmask;
        [branch]
        if (LCHmask > 0) {
            float shift, a, b;
            col = RGBToOKLAB(col);
            shift = _LCH1.z * PI2;
            sincos(shift, b, a);
            col.y = col.y * a - col.z * b;
            col.z = col.y * b + col.z * a;
            col *= _LCH1.xyy;
            col = OKLABToRGB(col);
        }
    #endif
    #if _ENABLE_LCH2_ON
        LCHmask = tex2D(_LCHMask2, i.uv).r;
        if (_Invert_LCH2 > 0) LCHmask = 1 - LCHmask;
        [branch]
        if (LCHmask > 0) {
            float shift, a, b;
            col = RGBToOKLAB(col);
            shift = _LCH2.z * PI2;
            sincos(shift, b, a);
            col.y = col.y * a - col.z * b;
            col.z = col.y * b + col.z * a;
            col *= _LCH2.xyy;
            col = OKLABToRGB(col);
        }
    #endif
    fixed3 effectCol = col;
    //-------------------------------------------------lighting-------------------------------------------------
    float3 reflectDir = reflect(i.viewDir, i.normal);
    float fresnel = 1 - DotClamped(i.normal, -i.viewDir);
    float nl = saturate(dot(i.normal, i.lightDirection));
    UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
    #if defined(FORWARD_BASE)
        fixed3 lighting = lerp(i.indirectLight, i.directLight, attenuation * (nl * 0.5 + 0.5));
        #if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH
            lighting += col * i.vertexLight;
            lighting = min(lighting, _MaxLighting);
        #endif
    #elif defined(FORWARD_ADD)
        fixed3 lighting = lerp(0, OPENLIT_LIGHT_COLOR, attenuation * (nl * 0.5 + 0.5));
    #endif
    lighting = min(lighting, _MaxLighting);
    col *= lighting;
    float3 reflection = 0..rrr;
    //-------------------------------------------------reflections-------------------------------------------------
    #if _ENABLE_REFLECTION_ON
        float roughness = 1 - _Smoothness;
        roughness *= 1.7 - 0.7 * roughness;
        float f4 = fresnel * fresnel * fresnel * fresnel;
        reflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, roughness * 6) * _Reflectivity * (f4 + _Reflectivity);

        float3 h = normalize(i.lightDirection - i.viewDir);
        float nh = saturate(dot(i.normal, h));

        roughness = max(roughness, 0.02);
        float r2 = roughness * roughness;
        float d = nh * nh * (r2 - 1.0) + 1.0;
        float ggx = r2 * r2 / (d * d);

        reflection += lighting * ggx * (4.0 * nh * nl) * (1 - roughness) * (50.0 * f4 + 1);
        col += reflection;
    #endif
    //-------------------------------------------------refraction-------------------------------------------------
    #if !defined(SHADER_API_MOBILE) && defined(FORWARD_BASE)
    [branch]
    if (mask > 0) {
        float3 r = normalize(refract(i.viewDir, i.normal, 1 / _Index));
        fixed4 background = saturate(raymarch(i.worldPos, r));
        //return float4(background.rgb, 1);
        float transparency = saturate((background.a * _DepthBlend) + _Blend);
        fixed3 slimeCol = background.rgb * transparency + col * (1 - transparency);
        fixed3 lumaCol = normalize(col - reflection + EPSILON) * LinearRgbToLuminance(slimeCol) + reflection;
        slimeCol = lumaCol * _ColorBlend + slimeCol * (1.0f - _ColorBlend);
        col = lerp(col, slimeCol, mask);
    }
    #endif
    //-------------------------------------------------effects-------------------------------------------------
    #if _ENABLE_EMISSION_ON
        col += effectCol * tex2D(_Emission, i.uv);
    #endif
    #if _ENABLE_RIMLIGHT_ON
        col += effectCol * pow(fresnel, _RimPow) * lighting;
    #endif
    #if _ENABLE_MATCAP_ON
        float3 n = i.viewDir;
        float3 b = float3(0, 1, 0);
        float3 t = cross(b, n);
        float2 capUV = mul(float3x3(t, b, n), i.normal);
        col += tex2Dlod(_MatCap1, float4(capUV * 0.5 + 0.5, 0, _MatCapBlur1)) * _MatCapCol1.rgb * _MatCapCol1.a * lighting;
        col += tex2Dlod(_MatCap2, float4(capUV * 0.5 + 0.5, 0, _MatCapBlur2)) * _MatCapCol2.rgb * _MatCapCol2.a * lighting;
    #endif

    UNITY_APPLY_FOG(i.fogCoord, col);
    return fixed4(col, 1);
}
#endif