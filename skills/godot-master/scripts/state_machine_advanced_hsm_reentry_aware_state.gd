class_name HSMReentryAwareState
extends Node

## Expert state with Re-entry Awareness.
## Distinguishes between fresh entry and being resumed from a stack.

func enter(msg: Dictionary = {}) -> void:
	if msg.get("is_resume", false):
		_on_resumed()
	else:
		_on_fresh_entry()

func _on_fresh_entry() -> void:
	# Trigger sound, start animation
	pass

func _on_resumed() -> void:
	# Keep current animation frame, just resume logic
	pass
