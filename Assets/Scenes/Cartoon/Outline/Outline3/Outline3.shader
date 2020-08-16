﻿Shader "Cartoon/Outline/Outline3"
{
// 基于过程几何轮廓——深度偏置
	Properties{
		_Color("Base Color", Color) = (0, 0, 0, 1)
		_DepthBiasing("_Depth Biasing", Range(0, 1)) = 0.2
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
	}
	SubShader{
		Tags{"RenderType"="Opaque" "Queue"="Geometry"}

		
		Pass{
			NAME "Outline3"

			Cull Front

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _DepthBiasing;
			float4 _OutlineColor;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
			};

			v2f vert(a2v v){
				v2f o;

				float4 pos = float4(UnityObjectToViewPos(v.vertex), 1.0);
				pos = pos + float4(0, 0 , 0.5, 0) * _DepthBiasing;
				o.pos = mul(UNITY_MATRIX_P, pos);

				return o;
			}

			float4 frag(v2f i) : SV_Target{
				return float4(_OutlineColor.rgb, 1);
			}

			ENDCG
		}

		Pass{
			Cull Back

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			float4 _Color;

			struct a2v{
				float4 vertex : POSITION;
			};

			struct v2f{
				float4 pos : POSITION;
			};

			v2f vert(a2v v){
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			float4 frag(v2f i):SV_Target{
				return _Color;
			}

			ENDCG
		}
	}
}
