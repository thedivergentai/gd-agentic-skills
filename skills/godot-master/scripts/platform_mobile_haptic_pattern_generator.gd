class_name HapticPatternGenerator
extends Node

## Expert haptic feedback system for Mobile triggers.
## Provides complex vibration lengths for feedback (Success, Failure, Impact).

func vibrate_success() -> void:
	# Short double pulse
	Input.vibrate_handheld(50)
	await get_tree().create_timer(0.1).timeout
	Input.vibrate_handheld(50)

func vibrate_failure() -> void:
	# Long heavy pulse
	Input.vibrate_handheld(400)

func vibrate_impact(intensity: float = 1.0) -> void:
	# Variable intensity vibration
	Input.vibrate_handheld(int(100 * intensity))
