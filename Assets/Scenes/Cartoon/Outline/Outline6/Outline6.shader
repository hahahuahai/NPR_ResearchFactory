Shader "SelfProgram/Outline6" // 2D图片描边效果，https://blog.csdn.net/qq_28299311/article/details/102922637
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_lineWidth("lineWidth", Range(0, 10)) = 1
		_lineColor("lineColor", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags{
			"Queue" = "Transparent"
		}
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _lineWidth;
			float4 _lineColor;

			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				if(col.a == 0)
					discard;
				// 采样周围4个点
				float2 up_uv = i.uv + float2(0, 1) * _lineWidth * _MainTex_TexelSize.xy;
				float2 down_uv = i.uv + float2(0, -1) * _lineWidth * _MainTex_TexelSize.xy;
				float2 left_uv = i.uv + float2(-1, 0) * _lineWidth * _MainTex_TexelSize.xy;
				float2 right_uv = i.uv + float2(1, 0) * _lineWidth * _MainTex_TexelSize.xy;
				// 如果有一个点透明度为0，说明是边缘
				float w = tex2D(_MainTex, up_uv).a * tex2D(_MainTex, down_uv).a * tex2D(_MainTex, left_uv).a * tex2D(_MainTex, right_uv).a;

				// 和原图做插值
				col.rgb = lerp(_lineColor, col.rgb, w);
				return col;
			}
			ENDCG
		}
	
	}
}
