class_name VRPerformanceConfig
extends Node

## Expert VR performance configurations (Foveation, VRS).
## Optimizes frame-time for 90/120Hz targets on standalone headsets.

func _ready() -> void:
	var xr_interface := XRServer.primary_interface
	if xr_interface:
		# Set foveation level (0 = Off, 4 = High)
		if "foveation_level" in xr_interface:
			xr_interface.foveation_level = 3 # High foveation for Quest 2
			xr_interface.foveation_dynamic = true

func set_supersampling(multiplier: float) -> void:
	# Multiplying render target size improves clarity at high GPU cost
	XRServer.primary_interface.render_target_size_multiplier = multiplier

## Rule: 90/120Hz is mandatory for comfort; favor resolution over post-effects.
