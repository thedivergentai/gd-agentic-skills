class_name ActionBufferInput
extends Node

## Foundational _unhandled_input buffer to decouple hardware events from frame-rate logic.
## Prevents UI click-through and captures raw events before SceneTree propagation.

@export var buffer_window_ms: int = 150
var _input_buffer: Dictionary = {}

func _unhandled_input(event: InputEvent) -> void:
	# Capture specific actions into a timestamped buffer
	if event.is_action_pressed(&"jump"):
		_buffer_action(&"jump")
		# Mark as handled to prevent propagation to UI or other layers
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed(&"attack"):
		_buffer_action(&"attack")
		get_viewport().set_input_as_handled()

func _buffer_action(action: StringName) -> void:
	_input_buffer[action] = Time.get_ticks_msec()

func is_action_buffered(action: StringName) -> bool:
	if _input_buffer.has(action):
		var delta = Time.get_ticks_msec() - _input_buffer[action]
		if delta <= buffer_window_ms:
			return true
	return false

func consume_action(action: StringName) -> void:
	_input_buffer.erase(action)
