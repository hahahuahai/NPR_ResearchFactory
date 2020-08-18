Shader "Cartoon/Shading/Shading2"
{
// 这个shader是对论文《stylized highlights for cartoon rendering and animation》的实现。学习风格化高光渲染。论文下载地址： http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.218.6114&rep=rep1&type=pdf		

	Properties{
			_BaseColor("Base Color", Color) = (1,1,0,1)
			_SpecularColor ("Specular Color", Color) = (1,1,1,1)
			_SpecularScale ("Specular Scale", Range(0, 0.05)) = 0.01
			_TranslationX ("Specular Translation X", Range(-1, 1)) = 0
			_TranslationY ("Specular Translation Y", Range(-1, 1)) = 0
			_RotationX ("Specular Rotation X", Range(-180, 180)) = 0
			_RotationY ("Specular Rotation Y", Range(-180, 180)) = 0
			_RotationZ ("Specular Rotation Z", Range(-180, 180)) = 0
			_ScaleX ("Specular Scale X", Range(-1, 1)) = 0
			_ScaleY ("Specular Scale Y", Range(-1, 1)) = 0
			_SplitX ("Specular Split X", Range(0, 1)) = 0
			_SplitY ("Specular Split Y", Range(0, 1)) = 0






			// 下面是轮廓线里面用到的属性
			_Outline("Outline", Range(0, 1)) = 0.04
			_OutlineColor("Outline Color", Color) = (0.5, 0.5, 0.5, 1)
	}

	SubShader{
		Tags {"RenderType"="Opaque" "LightMode"="ForwardBase"}

		//在此开始编码
		Pass{
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#pragma vertex vert
			#pragma fragment frag

			float4 _BaseColor;
			float4 _SpecularColor;
			float _SpecularScale;
			float _TranslationX;
			float _TranslationY;
			float _RotationX;
			float _RotationY;
			float _RotationZ;
			float _ScaleX;
			float _ScaleY;
			float _SplitX;
			float _SplitY;

			
			struct v2f{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float3 tsNormal : TEXCOORD1; // 切线空间的法线
				float3 tsLight : TEXCOORD2; // 切线空间的光照方向
				float3 tsView : TEXCOORD3; // 切线空间的视线方向
			};

			v2f vert(appdata_tan v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				TANGENT_SPACE_ROTATION;

				o.tsNormal = mul(rotation, v.normal);
				o.tsLight = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.tsView = mul(rotation, ObjSpaceViewDir(v.vertex));

				return o;
			}
			float4 frag(v2f i) : SV_TARGET
			{
				float3 tsNormal = normalize(i.tsNormal);
				float3 tsLight = normalize(i.tsLight);
				float3 tsView = normalize(i.tsView);
				float3 tsHalf = normalize(tsView + tsLight);

				// 1.缩放
				tsHalf = tsHalf - _ScaleX * tsHalf.x * float3(1, 0, 0);
				tsHalf = normalize(tsHalf);
				tsHalf = tsHalf - _ScaleY * tsHalf.y * float3(0, 1, 0);
				tsHalf = normalize(tsHalf);

				// 2.旋转
				// 度转弧度，1°= 0.0174533弧度
				#define DegreeToRadian 0.0174533  
				// 构建旋转矩阵
				float radianX = _RotationX * DegreeToRadian;
				float3x3 rotationMatX = float3x3(
					1,0,0,
					0,cos(radianX),sin(radianX),
					0,-sin(radianX),cos(radianX)
				);
				float radianY = _RotationY * DegreeToRadian;
				float3x3 rotationMatY = float3x3(
					cos(radianY),0,-sin(radianY),
					0,1,0,
					sin(radianY),0,cos(radianY)
				);
				float radianZ = _RotationZ * DegreeToRadian;
				float3x3 rotationMatZ = float3x3(
					cos(radianZ),sin(radianZ),0,
					-sin(radianZ),cos(radianZ),0,
					0,0,1
				);
				tsHalf = mul(rotationMatZ, mul(rotationMatY, mul(rotationMatX, tsHalf)));
				tsHalf = normalize(tsHalf);

				// 3.平移
				tsHalf = tsHalf + float3(_TranslationX, _TranslationY, 0);
				tsHalf = normalize(tsHalf);

				// 4.分裂split
				float signX = 1;
				if(tsHalf.x < 0)
					signX = -1;
				float signY = 1;
				if(tsHalf.y < 0)
					signY = -1;
				tsHalf = tsHalf - _SplitX * signX * float3(1,0,0) - _SplitY * signY * float3(0,1,0);
				tsHalf = normalize(tsHalf);

				// 5.方块化

				// 6.最终步骤
				float spec = dot(tsNormal, tsHalf);
				float w = fwidth(spec);
				float3 cartoonSpecular = lerp(float3(0, 0, 0), _SpecularColor.rgb, smoothstep(-w, w, spec + _SpecularScale - 1.0));

				// Compute the lighting model
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				return float4(ambient + cartoonSpecular, 1.0);
			}

			ENDCG
		}		
		UsePass "Cartoon/Outline/Outline2_2/Outline2_2"	
	}


}
