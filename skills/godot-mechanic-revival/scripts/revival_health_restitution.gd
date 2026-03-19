class_name RevivalHealthRestitution
extends Node

## Expert Health Restitution Logic.
## Handles 'Revive' item effects with temporary invincibility.

@export var i_frame_duration: float = 2.0

func apply_revive(target: Node) -> void:
	if target.has_method("set_invincible"):
		target.set_invincible(true)
		
		# Visual Feedback: Pulsing opacity
		var tween = target.create_tween().set_loops(4)
		tween.tween_property(target, "modulate:a", 0.2, 0.25)
		tween.tween_property(target, "modulate:a", 1.0, 0.25)
		
		await target.get_tree().create_timer(i_frame_duration).timeout
		target.set_invincible(false)

## Rule: Invincibility frames (I-frames) are mandatory after revival to prevent 'Death Loops'.
