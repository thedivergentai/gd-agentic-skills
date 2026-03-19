# Safe Tween Lifecycle Manager
extends Node

## Tweens in Godot 4 are lightweight, but fighting and leaks are common.
## This pattern ensures interruptions are handled gracefully.

var _active_tween: Tween

func play_safe_ui_pop(target_node: Control) -> void:
	# MANDATORY: Kill previous tween before overwriting to prevent logic fights
	if _active_tween:
		_active_tween.kill()
		
	_active_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK)
	
	# Chain animations safely
	_active_tween.tween_property(target_node, "scale", Vector2.ONE, 0.3).from(Vector2.ZERO)
	_active_tween.tween_property(target_node, "modulate:a", 1.0, 0.2).from(0.0)
	
	# Cleanup reference when done
	_active_tween.finished.connect(func(): _active_tween = null)

func interrupt_all_tweens() -> void:
	if _active_tween:
		_active_tween.kill()
