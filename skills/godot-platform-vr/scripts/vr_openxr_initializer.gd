class_name VROpenXRInitializer
extends Node

## Expert OpenXR initialization with feature support checking.
## Ensures the XR system is only activated if the hardware is ready.

func _ready() -> void:
	var xr_interface: XRInterface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("VR: OpenXR already initialized.")
		_setup_viewport()
	elif xr_interface and xr_interface.initialize():
		print("VR: OpenXR Initialized successfully.")
		_setup_viewport()
	else:
		push_error("VR: OpenXR initialization failed. Headset not found?")

func _setup_viewport() -> void:
	get_viewport().use_xr = true
	# Expert: VSync should always be OFF in VR to avoid latency (headset handles pacing)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

## Rule: Always check 'xr_interface.initialize()' before setting 'use_xr = true'.
