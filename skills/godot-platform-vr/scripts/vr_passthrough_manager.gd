class_name VRPassthroughManager
extends Node

## Expert AR Passthrough (Mixed Reality) manager for OpenXR.
## Enables the world-view underlay for Meta Quest and other MR headsets.

func enable_passthrough(enabled: bool) -> void:
	var xr_interface := XRServer.primary_interface
	if xr_interface and xr_interface.get_name() == "OpenXR":
		if enabled:
			xr_interface.set_environment_blend_mode(XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND)
			get_viewport().transparent_bg = true
		else:
			xr_interface.set_environment_blend_mode(XRInterface.XR_ENV_BLEND_MODE_OPAQUE)
			get_viewport().transparent_bg = false

## Rule: Passthrough requires 'transparent_bg = true' on the main viewport.
