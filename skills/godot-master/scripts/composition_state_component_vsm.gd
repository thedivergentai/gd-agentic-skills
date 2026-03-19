# state_component_vsm.gd
# Component-based state machine pattern
class_name StateComponent extends Node

# EXPERT NOTE: Each state is a child node. The parent component 
# manages transitions between them.

signal state_changed(new_state: String)

var current_state: Node = null

func transition_to(state_name: String) -> void:
	var next_state = get_node_or_null(state_name)
	if next_state:
		if current_state: current_state.exit()
		current_state = next_state
		current_state.enter()
		state_changed.emit(state_name)
