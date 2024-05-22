Shader "Slime" {
    Properties {
        _SlimeColor ("Slime Color", Color) = (1, 1, 1, 0.5)
        [NoScaleOffset]_SlimeTex ("Slime Texture", 2D) = "white" {}
        [NoScaleOffset]_SlimeMask ("Slime Mask (R)", 2D) = "white" {}
        [MainColor]_MainColor ("Main Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset][MainTexture]_MainTex ("Main Texture", 2D) = "white" {}
        [Toggle]_Enable_LCH1 ("LCH 1 Enabled", Float) = 0
        [Toggle]_Invert_LCH1 ("LCH 1 Mask Inverted", Float) = 0
        [NoScaleOffset]_LCHMask1 ("LCH 1 Mask (R)", 2D) = "white" {}
        _LCH1 ("LCH 1 (XYZ)", Vector) = (1, 1, 0, 0)
        [Toggle]_Enable_LCH2 ("LCH 2 Enabled", Float) = 0
        [Toggle]_Invert_LCH2 ("LCH 2 Mask Inverted", Float) = 0
        [NoScaleOffset]_LCHMask2 ("LCH 2 Mask (R)", 2D) = "white" {}
        _LCH2 ("LCH 2 (XYZ)", Vector) = (1, 1, 0, 0)
        [Toggle]_Enable_Emission ("Emission Enabled", Float) = 0
        [NoScaleOffset]_Emission ("Emission", 2D) = "black" {}
        [Toggle]_Enable_MatCap ("MatCap Enabled", Float) = 0
        [NoScaleOffset]_MatCap1 ("MatCap 1", 2D) = "black" {}
        _MatCapCol1 ("MatCap Color 1", Color) = (1, 1, 1, 1)
        _MatCapBlur1 ("MatCap Blur 1", Float) = 0
        [NoScaleOffset]_MatCap2 ("MatCap 2", 2D) = "black" {}
        _MatCapCol2 ("MatCap Color 2", Color) = (1, 1, 1, 1)
        _MatCapBlur2 ("MatCap Blur 2", Float) = 0
        [Toggle]_Enable_Normal1 ("Normal Map 1 Enabled", Float) = 0
        [Normal]_BumpMap1 ("Normal Map 1", 2D) = "bump" {}
        [Toggle]_Enable_Normal2 ("Normal Map 2 Enabled", Float) = 0
        [Normal]_BumpMap2 ("Normal Map 2", 2D) = "bump" {}
        _BumpPow ("Normal Strength", Range(0, 5)) = 1
        [Toggle]_Enable_Height ("Height Enabled", Float) = 0
        [NoScaleOffset]_HeightMap ("Height Map", 2D) = "black" {}
        _HeightPow ("Height Strength", Range(-1, 1)) = 0.1
        _HeightScale ("Height Scale", Float) = 1
        [Toggle]_Enable_RimLight ("RimLight Enabled", Float) = 0
        _RimPow ("Rim Power", Range(0, 10)) = 3
        [Toggle]_Enable_Reflection ("Reflections Enabled", Float) = 0
        [Gamma]_Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 1
        _Reflectivity ("Reflectivity", Range(0, 1)) = 0.05
        _Index ("Refraction Index", Range(0, 5)) = 1.1
        _MinLighting ("Min Lighting", Range(0, 1)) = 0.05
        _MaxLighting ("Max Lighting", Range(0, 1)) = 1
        _Monochrome ("Monochrome Lighting", Range(0, 1)) = 0.5
        [Toggle]_Enable_Bulge ("Bulge Enabled", Float) = 0
        _Bulge ("Bulge Amount", Float) = 0.05
        _BulgeDist ("Bulge Distance", Float) = 0.05
        [Toggle]_Enable_Blur ("Blur Enabled", Float) = 0
        _Blend ("Slime Transparency", Range(0, 1)) = 0.8
        _DepthBlend ("Depth Transparency", Range(0, 1)) = 0
        _ColorBlend ("Color Power", Range(0, 1)) = 0.5
    }
    SubShader {
        Tags {"RenderType" = "Transparent" "Queue" = "Transparent+10"}
        ColorMask RGB
        GrabPass { "_SlimeGrab" }
        Pass {
            Name "ForwardBase"
            Tags {"LightMode" = "ForwardBase"}
            ZWrite On
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #define FORWARD_BASE
            #include "Slime.hlsl"
            ENDCG
        }
        Pass {
            Name "ForwardAdd"
            Tags {"LightMode" = "ForwardAdd"}
            Blend One One
            ZWrite Off
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #define FORWARD_ADD
            #include "Slime.hlsl"
            ENDCG
        }
    }
    Fallback "Standard"
}