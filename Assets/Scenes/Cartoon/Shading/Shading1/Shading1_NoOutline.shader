Shader "Cartoon/Shading/Shading1_NoOutline"
{
	Properties{
		_BaseFrontColor("Base Front Color", Color) = (1,1,1,1)
		_BaseBackColor("Base Back Color", Color) = (1,1,1,1)
		_CoolColor("Cool Color", Color) = (1,1,1,1)
		_WarmColor("Warm Color", Color) = (1,1,1,1)
		_CoolAlpha("Cool Alpha", Range(0, 1)) = 0.5
		_WarmBeta("Warm Beta", Range(0, 1)) = 0.5
	}

	SubShader{
		Tags{"RenderType"="Opaque"}

		UsePass "Cartoon/Shading/Shading1/Shading1"
	}
}
