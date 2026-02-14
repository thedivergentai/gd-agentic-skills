# skills/input-handling/scripts/input_buffer.gd
extends Node

## Input Buffer Expert Pattern
## Buffers inputs for responsive controls - press jump 100ms before landing? Still registers.

class_name InputBuffer

var _buffer: Dictionary = {}  # action_name → buffer time remaining
@export var buffer_duration: float = 0.15  # 150ms

func _process(delta: float) -> void:
	# Decay all buffered inputs
	for action in _buffer.keys():
		_buffer[action] -= delta
		if _buffer[action] <= 0:
			_buffer.erase(action)

func buffer_action(action_name: String) -> void:
	_buffer[action_name] = buffer_duration

func is_action_buffered(action_name: String) -> bool:
	return action_name in _buffer

func consume_action(action_name: String) -> bool:
	if action_name in _buffer:
		_buffer.erase(action_name)
		return true
	return false

## EXPERT USAGE:
## In _unhandled_input():
##   if Input.is_action_just_pressed("jump"):
##     input_buffer.buffer_action("jump")
##
## In _physics_process():
##   if is_on_floor() and input_buffer.consume_action("jump"):
##     velocity.y = JUMP_VELOCITY
