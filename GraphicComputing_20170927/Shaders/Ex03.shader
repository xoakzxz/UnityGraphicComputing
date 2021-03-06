﻿Shader "Custom/Ex03" {
	
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
	}

	SubShader {
		Tags { "RenderType" = "Opaque" }
		
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert addshadow
		#pragma target 3.0

		sampler2D _MainTex;
		float4 _Color;

		struct Input {
			float2 uv_MainTex;
		};

		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard output) {
			// Tex info
			float4 texInfo = tex2D (_MainTex, IN.uv_MainTex);
			// Output setup
			output.Albedo = texInfo * _Color.rgb;
		}

		void vert (inout appdata_full v, out Input IN) {
			UNITY_INITIALIZE_OUTPUT(Input, IN);

			// Reading coordinates
			float x = v.vertex.x;
			float y = v.vertex.y;
			float z = v.vertex.z;

			float paraboloid = x*x - z*z;

			float newX = x;
			float newY = 0.3 * y + 0.7 * paraboloid;
			float newZ = z;

			// Vertex setup
			v.vertex.xyz = float3(newX, newY, newZ);
			v.normal = normalize(v.normal.xyz);
		}

		ENDCG
	}
	FallBack "Diffuse"
}
