# advanced_input_buffer.gd
# Frame-perfect input buffering for combos and responsive feel [12, 13]
extends Node

# EXPERT NOTE: Simple buffering just checks "was jump pressed". 
# Advanced buffering tracks the 'time_since_pressed' for multiple 
# actions to allow priority-based execution (e.g. Dash over Jump).

var _buffer: Dictionary = {} # action_name -> timestamp
@export var buffer_window_ms: int = 150

func _input(event: InputEvent) -> void:
	for action in ["jump", "dash", "attack"]:
		if event.is_action_pressed(action):
			_buffer[action] = Time.get_ticks_msec()

func is_action_buffered(action: String) -> bool:
	if _buffer.has(action):
		var delta = Time.get_ticks_msec() - _buffer[action]
		if delta <= buffer_window_ms:
			return true
	return false

func consume_buffer(action: String) -> void:
	_buffer.erase(action)
