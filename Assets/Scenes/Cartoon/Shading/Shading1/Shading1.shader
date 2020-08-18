Shader "Cartoon/Shading/Shading1"
{
// 实现Gooch的面向工程图渲染的艺术化光照模型（即基于色调的渲染技术）。https://dl.acm.org/doi/abs/10.1145/280814.280950
	Properties{
		_BaseFrontColor("Base Front Color", Color) = (1,1,1,1)
		_BaseBackColor("Base Back Color", Color) = (1,1,1,1)
		_CoolColor("Cool Color", Color) = (1,1,1,1)
		_WarmColor("Warm Color", Color) = (1,1,1,1)
		_CoolAlpha("Cool Alpha", Range(0, 1)) = 0.5
		_WarmBeta("Warm Beta", Range(0, 1)) = 0.5

		_Outline("Outline", Range(0, 1)) = 0.04
		_OutlineColor("Outline Color", Color) = (0.5, 0.5, 0.5, 1)
	}

	SubShader{
		Tags{"RenderType"="Opaque"}

		Pass{
			NAME "Shading1"
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v{
				float4 vertex :POSITION;
				float4 normal : NORMAL;
			};

			struct v2f{
				float4 vertex : SV_POSITION;
				float3 worldNormal :TEXCOORD0;
				float3 worldLightDir : TEXCOORD1;
			};

			float4 _BaseFrontColor;
			float4 _BaseBackColor;
			float4 _CoolColor;
			float4 _WarmColor;
			float _CoolAlpha;
			float _WarmBeta;

			v2f vert(a2v v){
				v2f o;
				o.worldNormal = UnityObjectToWorldNormal(v.normal.xyz);
				o.worldLightDir = normalize(WorldSpaceLightDir(v.vertex));
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i): SV_Target
			{
				float IdotN = dot(-i.worldLightDir, i.worldNormal); // -i.worldLightDir：用光源指向片元的方向，而不是光源的方向
				fixed4 BaseColor = _BaseFrontColor * (1 - IdotN) + _BaseBackColor * IdotN;
				_CoolColor = _CoolColor + _CoolAlpha * BaseColor;
				_WarmColor = _WarmColor + _WarmBeta * BaseColor;
				fixed4 I = (0.5 + IdotN * 0.5) * _CoolColor + (0.5 - IdotN * 0.5) * _WarmColor;
				return I;
			}

			ENDCG
		}


		UsePass "Cartoon/Outline/Outline2_2/Outline2_2"
	}
}
