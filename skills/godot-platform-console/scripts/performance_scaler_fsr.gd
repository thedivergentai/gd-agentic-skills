class_name PerformanceScalerFSR
extends Node

## Expert Dynamic Resolution Scaling and FSR 2.2 management.
## Optimized for weak hardware (Nintendo Switch) using temporal upscaling.

func apply_performance_profile(viewport: Viewport, profile: StringName = &"balanced") -> void:
	# Forward+ renderer supports FSR2 natively
	viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
	
	match profile:
		&"performance":
			viewport.scaling_3d_scale = 0.5 # 540p -> 1080p
			viewport.fsr_sharpness = 0.4
		&"balanced":
			viewport.scaling_3d_scale = 0.67 # ~720p -> 1080p
			viewport.fsr_sharpness = 0.2
		&"quality":
			viewport.scaling_3d_scale = 0.85
			viewport.fsr_sharpness = 0.1

## Expert: Lower mipmap bias automatically follows scaling_3d_scale in Godot 4.
