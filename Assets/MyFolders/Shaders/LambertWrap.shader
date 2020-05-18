﻿Shader "Custom/LambertWrap"
{
	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_NormalTex("Normal Map", 2D) = "white" {}
	}
		SubShader{
		Tags { "RenderType" = "Opaque" }
		CGPROGRAM
		  #pragma surface surf WrapLambert

		  half4 LightingWrapLambert(SurfaceOutput s, half3 lightDir, half atten) {
			  half NdotL = dot(s.Normal, lightDir);
			  half diff = NdotL * 0.5 + 0.5;
			  half4 c;
			  c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten); //Surface scattering effects
			  c.a = s.Alpha;
			  return c;
		  }

		struct Input {
			float2 uv_MainTex;
			float2 uv_NormalMap;
		};

		sampler2D _MainTex;
		sampler2D _NormalMap;

		void surf(Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
		}
		ENDCG
	}
		Fallback "Diffuse"
}
