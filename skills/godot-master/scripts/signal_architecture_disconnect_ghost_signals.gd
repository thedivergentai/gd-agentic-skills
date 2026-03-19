# disconnect_ghost_signals.gd
# Memory management when switching tracking targets
extends Node

var current_target: Node

func track_new_entity(entity: Node):
	# Cleanup old connection to prevent memory/logic leaks
	if current_target and current_target.died.is_connected(_on_target_died):
		current_target.died.disconnect(_on_target_died)
		
	current_target = entity
	current_target.died.connect(_on_target_died)

func _on_target_died():
	print("Current target lost.")
