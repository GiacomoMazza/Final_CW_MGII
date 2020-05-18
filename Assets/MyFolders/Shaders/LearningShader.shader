Shader "Custom/LearningShader"
{
    Properties
    {
		 _MyTexture ("My texture", 2D) = "white" {}
		 _MyNormalMap ("My normal map", 2D) = "bump" {} // Grey
		 
		 _MyInt ("My integer", Int) = 2
		 _MyFloat ("My float", Float) = 1.5
		 _MyRange ("My range", Range(0.0, 1.0)) = 0.5
		 
		 _MyColor ("My colour", Color) = (1, 0, 0, 1) // (R, G, B, A)
		 _MyVector ("My Vector4", Vector) = (0, 0, 0, 0) // (x, y, z, w)
    }
    SubShader
    {
		Tags
		{
		"Queue" = "Geometry"
		"RenderType" = "Opaque"
		}

		CGPROGRAM

		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
		
		//Use Lambertian lighting model
		#pragma surface surf Lambert

		// Code of the shader
		// ...
		sampler2D _MyTexture;
		sampler2D _MyNormalMap;
		
		int _MyInt;
		float _MyFloat;
		float _MyRange;
		
		half4 _MyColor;
		float4 _MyVector;
		
		// Code of the shader
		// ...

		struct Input
		{
			float2 uv_MyTexture;
			float2 uv_MyNormalMap;
		};

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			o.Albedo = tex2D(_MyTexture, IN.uv_MyTexture).rgb;
			o.Normal = UnpackNormal(tex2D(_MyNormalMap, IN.uv_MyNormalMap));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
