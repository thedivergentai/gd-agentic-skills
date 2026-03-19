class_name EasterSquashStretchJuice
extends Node

## Expert squash and stretch 'juice' for interactive objects (Eggs).
## Uses a single Tween to generate organic physical responses.

@export var target_spatial: Node3D

func apply_impact_juice(intensity: float = 0.2) -> void:
	if not target_spatial: return
	
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Squash: Flatten Y, Widen X/Z
	tween.tween_property(target_spatial, "scale", Vector3(1.0 + intensity, 1.0 - intensity, 1.0 + intensity), 0.1)
	# Snap back to normal
	tween.tween_property(target_spatial, "scale", Vector3.ONE, 0.4)

## Tip: Trigger this on '_on_body_entered' or mouse click for maximum feedback.
