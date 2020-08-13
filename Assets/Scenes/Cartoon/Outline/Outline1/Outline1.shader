Shader "Cartoon/Outline/Outline1"
{
	//基于观察角度和表面法线的轮廓线渲染
	Properties{
		_Color("Base Color", Color) = (0, 0, 0, 1)
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineWidth("Outline Width", float) = 0.8
	}
	SubShader{
		Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

		Pass{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4 _Color;
			float4 _OutlineColor;
			float _OutlineWidth;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;				
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			float4 frag(v2f i) : SV_Target {
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float diff = dot(worldNormal, worldViewDir);
				float diff_OneMinus = 1 - diff;
				float3 outline = (0, 0, 0);
				float value = diff_OneMinus - _OutlineWidth;
				if(value > 0)
					outline = _OutlineColor * diff_OneMinus;
				return float4(outline, 1.0);
			}

			ENDCG
		}
	}
}
