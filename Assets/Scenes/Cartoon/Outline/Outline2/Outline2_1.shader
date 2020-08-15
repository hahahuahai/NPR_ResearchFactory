Shader "Cartoon/Outline/Outline2_1"
{
// 基于过程几何轮廓——法向偏置（先渲染正面，再渲染背面）
	Properties{
		_Color("Base Color", Color) = (0, 0, 0, 1)
		_Outline("Outline", Range(0, 1)) = 0.2
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
	}
	SubShader{
		Tags{"RenderType"="Opaque" "Queue"="Geometry"}

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
		Pass{
			Cull Front

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _Outline;
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
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				normal.z = -0.5;
				pos = pos + float4(normalize(normal), 0) * _Outline;
				o.pos = mul(UNITY_MATRIX_P, pos);

				return o;
			}

			float4 frag(v2f i) : SV_Target{
				return float4(_OutlineColor.rgb, 1);
			}

			ENDCG
		}
	}
}
