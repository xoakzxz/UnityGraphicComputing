﻿Shader "Hidden/CameraMaskTexture"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Texture("Texture", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		_TexelSize("Texel Size", Float) = 1
	}
	
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"

			//PROPERTIES!
			sampler2D _MainTex;
			sampler2D _Texture;
			sampler2D _Mask;
			float4 _MainTex_TexelSize;
			float _TexelSize;

			//CONVULTION FUNCTION!
			inline float3 Convultion(float2 uv, float2 texelSize, float3x3 kernel)
			{
				float4 finalColor;

				for (int row = 0; row < 3; row++) //The same operation with for cycles
				{
					for (int column = 0; column < 3; column++)
					{
						//new UV
						float2 newUV = float2(
							(uv.x - texelSize.x) + column * texelSize.x,
							(uv.y - texelSize.y) + row * texelSize.y
							);

						//New color
						float4 newColor = tex2D(_MainTex, newUV);

						//Returned color
						finalColor += newColor * kernel[row][column];
					}
				}

				return finalColor;
			}

			inline float Sobel(float xSobel, float ySobel)
			{
				return sqrt((xSobel * xSobel) + (ySobel * ySobel));
			}

			//FRAG FUNCTION!
			float4 frag (v2f_img i) : SV_Target
			{
				float2 texelSize = _MainTex_TexelSize * _TexelSize;

				float4 originalImage = tex2D(_MainTex, i.uv);
				
				float4 textureInfo = tex2D(_Texture, i.uv);
				
				//SOBEL! ***
				float3x3 xSobelKernel = float3x3(
					1.0, 2.0, 1.0, //First row
					0.0, 0.0, 0.0, //Second row
					-1.0, -2.0, -1.0 //Third row
				);

				float3x3 ySobelKernel = transpose(xSobelKernel);

				float4 xSobelColor;
				
				xSobelColor.rgb = Convultion(i.uv, texelSize, xSobelKernel);

				float4 ySobelColor;

				ySobelColor.rgb = Convultion(i.uv, texelSize, xSobelKernel);

				float sobelColor = Sobel(xSobelColor.r, ySobelColor.r);

				//MASK! ***
				float mask = tex2D(_Mask, i.uv);
				
				float4 finalColor = (mask * originalImage * textureInfo) + ((1 - mask) * sobelColor);

				return finalColor;
			}

			ENDCG
		}
	}
}
