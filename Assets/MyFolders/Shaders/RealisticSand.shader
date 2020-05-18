//Acknowledgments - This code comes from different places on the internet and my own creativity 
//and implementation of different theories. Thanks to:
//Alan Zucconi: https://www.alanzucconi.com/2019/10/08/journey-sand-shader-1/
//Barré-Brisebois Colin and Stephen Hill: https://blog.selfshadow.com/publications/blending-in-detail/
//Unity Forums: https://forum.unity.com/threads/2-normal-map-shader-lightmapping.199005/
//Unity Manual: https://docs.unity3d.com/Manual/SL-SurfaceShaderLightingExamples.html

Shader "Custom/RealisticSand"
{
	Properties
	{
		//Main texture variable
		_MainTex("Albedo", 2D) = "white" {}

		//Diffuse variables
		_TerrainColour("Terrain Colour", Color) = (1,1,1,1)
		_ShadowColour("Shadow Colour", Color) = (1,1,1,1)

		//Main Sand variables
		_SandTex("Sand Bitmap", 2D) = "white" {}
		_SandStrength("Density Sand", Float) = 0.2

		//FresnelEffect variables
		_TerrainRimPower("Terrain Rim Power", Float) = 1
		_TerrainRimStrength("Terrain Rim Power", Float) = 1
		_TerrainRimColour("Terrain Rim Colour", Color) = (1,1,1,1)

		//Ripples variables
		_DetailRipple("Detail Normal Texture", 2D) = "white" {}
		_RippleNormalMap("Ripples Normal Texture", 2D) = "white" {}

	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			#pragma surface surf RealisticSand fullforwardshadows
			#pragma target 4.0

			sampler2D _MainTex;

			struct Input
			{
				float2 uv_MainTex;

				float3 worldPos;

				float3 worldNormal;
				INTERNAL_DATA
			};

			//Normal Lerp: method between lerp and slerp with similar results.
			float3 worldPos;

			inline float3 nlerp(float3 n1, float3 n2, float t)
			{
				return normalize(lerp(n1, n2, t));
			}

			//DIFFUSE
			float3 _TerrainColour;
			float3 _ShadowColour;

			float3 DiffuseColour(float3 N, float3 L)
			{
				N.y *= 0.3;
				float NdotL = saturate(4 * dot(N, L));

				float3 colour = lerp(_ShadowColour, _TerrainColour, NdotL);
				return colour;
			}

			//SAND NORMAL
			sampler2D_float _SandTex;
			float4 _SandTex_ST;
			float _SandStrength;

			float3 SandNormal(float3 W, float3 N)
			{
				float2 W2 = W.xz;

				float3 random = tex2D(_SandTex, TRANSFORM_TEX(W2, _SandTex)).rgb;

				float3 S = normalize(random * 2 - 1);

				float3 Ns = nlerp(N, S, _SandStrength);
				return Ns;
			}

			//RIM LIGHTING
			float _TerrainRimPower;
			float _TerrainRimStrength;
			float3 _TerrainRimColour;

			float3 FresnelEffect(float3 N, float3 V)
			{
				float rim = 1.0 - saturate(dot(N, V));
				rim = saturate(pow(rim, _TerrainRimPower) * _TerrainRimStrength); //-0.4 TOON
				rim = max(rim, 0); // Never negative
				return rim * _TerrainRimColour;
			}

			//RIPPLES
			sampler2D_float _DetailRipple;
			sampler2D_float _RippleNormalMap;
			float4 _DetailRipple_ST;
			float4 _RippleNormalMap_ST;

			float3 RipplesNormal(float3 W)
			{
				float2 uv = W.xz;

				/*float3 Ripple = UnpackNormal(tex2D(_RippleNormalMap, TRANSFORM_TEX(uv, _RippleNormalMap)));
				float3 RippleDetail = UnpackNormal(tex2D(_DetailRipple, TRANSFORM_TEX(uv, _DetailRipple)));
				Ripple += float3(0, 0, 1);
				RippleDetail *= float3(-1, -1, 1);
				return Ripple * dot(Ripple, RippleDetail) / Ripple.z - RippleDetail;*/

				float3 Ripple = UnpackNormal(tex2D(_RippleNormalMap, TRANSFORM_TEX(uv, _RippleNormalMap)));
				float3 RippleDetail = UnpackNormal(tex2D(_DetailRipple, TRANSFORM_TEX(uv, _DetailRipple)));

				Ripple *= 2 - 1;
				RippleDetail *= 2 - 1;

				float a = 1 / (1 + Ripple.z);
				float b = -Ripple.x*Ripple.y*a;

				float3 b1 = float3(1 - Ripple.x*Ripple.x*a, b, -Ripple.x);
				float3 b2 = float3(b, 1 - Ripple.y*Ripple.y*a, -Ripple.y);
				float3 b3 = Ripple;

				if (Ripple.z < -0.9999999) //handle exception
				{
					b1 = float3(0, -1, 0);
					b2 = float3(-1, 0, 0);
				}

				float3 r = RippleDetail.x*b1 + RippleDetail.y*b2 + RippleDetail.z*b3;

				return r * 0.5 + 0.5;
			}

			inline float4 LightingRealisticSand(SurfaceOutput s, fixed3 viewDir, UnityGI gi)
			{
				float3 L = gi.light.dir;
				float3 N = s.Normal;
				float3 V = viewDir;
				float3 W = worldPos;

				float3 diffuseColour = DiffuseColour(N, L);
				float3 rimColour = FresnelEffect(N, V);

				float3 colour = diffuseColour + rimColour;

				return float4(colour * s.Albedo, 1);
			}

			void LightingRealisticSand_GI(SurfaceOutput s, UnityGIInput data, inout UnityGI gi)
			{

			}

			void surf(Input IN, inout SurfaceOutput o)
			{
				half3 mainTexture = tex2D(_MainTex, IN.uv_MainTex);
				o.Albedo = mainTexture;

				worldPos = IN.worldPos;
				float3 W = worldPos;
				float3 N = float3(0, 0, 1);

				N = RipplesNormal(W);
				N = SandNormal(W, N) + o.Normal;

				o.Normal = N;
			}
			ENDCG
		}
	FallBack "Diffuse"
}