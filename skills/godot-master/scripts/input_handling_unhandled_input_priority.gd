# unhandled_input_priority.gd
# Expert use of _unhandled_input across the tree [26]
extends Node2D

# 1. _input() -> Global (always)
# 2. Control._gui_input() -> UI only
# 3. _unhandled_input() -> Gameplay (only if UI didn't use it)
# 4. _unhandled_key_input() -> Shortcuts

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		# This interaction only triggers if the player didn't 
		# just click a 'Use' button on a menu!
		_check_interaction()

func _check_interaction():
	pass
