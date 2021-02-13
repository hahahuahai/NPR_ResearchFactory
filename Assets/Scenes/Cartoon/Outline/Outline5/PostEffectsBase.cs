using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
	// Called when start
	protected void CheckResources()
	{
		bool isSupported = CheckSupport();

		if (isSupported == false)
		{
			NotSupported();
		}
	}

	// Called in CheckResources to check support on this platform
	protected bool CheckSupport()
	{
		if (SystemInfo.supportsImageEffects == false)
		{
			Debug.LogWarning("This platform does not support image effects.");
			return false;
		}

		return true;
	}

	// Called when the platform doesn't support this effect
	protected void NotSupported()
	{
		enabled = false;
	}

	protected void Start()
	{
		CheckResources();
	}

	protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
        {
			return null;
        }
        if (shader.isSupported && material && material.shader == shader)
        {
			return material;
        }
        else
        {
			material = new Material(shader);
			material.hideFlags = HideFlags.DontSave;
            if (material)
            {
				return material;
            }
            else
            {
				return null;
            }
        }
    }
}
