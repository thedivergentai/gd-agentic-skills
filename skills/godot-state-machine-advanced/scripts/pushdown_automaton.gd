# skills/state-machine-advanced/scripts/pushdown_automaton.gd
extends Node

## Pushdown Automaton Expert Pattern
## Stack-based state machine for interrupt-resume behavior (pause menu, cutscene, item pickup).

class_name PushdownAutomaton

signal state_changed(from_state: String, to_state: String)

var _state_stack: Array[Node] = []
var _current_state: Node = null

func _ready() -> void:
	for child in get_children():
		child.set_meta("_fsm", self)
	
	if get_child_count() > 0:
		_transition_to(get_child(0))

func transition_to(state_name: String) -> void:
	var new_state := get_node_or_null(state_name)
	if not new_state:
		push_error("State not found: %s" % state_name)
		return
	_transition_to(new_state)

func push_state(state_name: String) -> void:
	if _current_state:
		if _current_state.has_method("pause"):
			_current_state.pause()
		_state_stack.append(_current_state)
	
	transition_to(state_name)

func pop_state() -> void:
	if _state_stack.is_empty():
		push_warning("Attempted to pop empty state stack")
		return
	
	var previous_state := _state_stack.pop_back()
	_transition_to(previous_state)
	
	if previous_state.has_method("resume"):
		previous_state.resume()

func _transition_to(new_state: Node) -> void:
	var old_name := _current_state.name if _current_state else ""
	
	if _current_state and _current_state.has_method("exit"):
		_current_state.exit()
	
	_current_state = new_state
	
	if _current_state.has_method("enter"):
		_current_state.enter()
	
	state_changed.emit(old_name, new_state.name)

func update(delta: float) -> void:
	if _current_state and _current_state.has_method("update"):
		_current_state.update(delta)

func physics_update(delta: float) -> void:
	if _current_state and _current_state.has_method("physics_update"):
		_current_state.physics_update(delta)

## EXPERT USAGE:
## Enemy AI: Patrol → [push Attack] → [pop back to Patrol]
## Player: Gameplay → [push Pause Menu] → [pop back to Gameplay]
##
## State scripts implement optional: enter(), exit(), pause(), resume()
