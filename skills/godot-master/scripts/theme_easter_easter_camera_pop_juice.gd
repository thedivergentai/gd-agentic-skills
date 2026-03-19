class_name EasterCameraPopJuice
extends Camera3D

## Expert camera juice for 'Egg Pops' or collection events.
## Pulses the FOV temporarily to emphasize the impact.

func trigger_pop_kick(strength: float = 5.0) -> void:
	var base_fov := fov
	var tween := create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "fov", base_fov + strength, 0.05)
	tween.tween_property(self, "fov", base_fov, 0.2)

## Rule: FOV kicks should be subtle (< 10 degrees) to avoid motion sickness.
