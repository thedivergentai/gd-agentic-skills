class_name AudioOcclusionRaycast
extends RayCast3D

## Expert Audio Occlusion logic.
## Dynamically applies LowPassFilter when the line-of-sight is blocked.

@export var audio_player: AudioStreamPlayer3D
var low_pass: AudioEffectLowPassFilter

func _ready() -> void:
	# Assume bus index 1 has the low pass filter
	low_pass = AudioServer.get_bus_effect(audio_player.bus_index, 0) as AudioEffectLowPassFilter

func _physics_process(_delta: float) -> void:
	target_position = get_viewport().get_camera_3d().global_position
	
	var is_occluded = is_colliding()
	var target_freq = 500.0 if is_occluded else 20000.0
	
	# Smoothly lerp the muffling effect
	low_pass.cutoff_hz = lerp(low_pass.cutoff_hz, target_freq, 0.1)

## Tip: Use this for realistic sound propagation in first-person/stealth games.
