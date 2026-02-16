class_name InputSequenceWatcher
extends Node

## A node that listens for a specific sequence of input actions.
## Useful for cheat codes (Konami Command) or hidden input mechanics.

signal sequence_matched

## The target sequence of input actions (strings corresponding to InputMap actions).
@export var target_sequence: Array[String] = []

## Maximum time allowed between inputs before the buffer resets.
@export var timeout: float = 1.0

## If true, the buffer resets immediately after a successful match.
@export var reset_on_match: bool = true

var _current_buffer: Array[String] = []
var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = timeout
	_timer.timeout.connect(_reset_buffer)
	add_child(_timer)

func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	
	# Check all defined actions to see if one was just pressed
	# We iterate the InputMap actions because event.as_text() is unreliable for logical mapping
	var matched_action = ""
	for action in InputMap.get_actions():
		if event.is_action_pressed(action):
			matched_action = action
			break
	
	if matched_action != "":
		_process_input(matched_action)

func _process_input(action_name: String) -> void:
	# Reset the timer on any valid input to keep the "combo" alive
	_timer.start()
	
	# Append to buffer
	_current_buffer.append(action_name)
	
	# Optimization: If the buffer is longer than the target, we can slice it
	# providing a "rolling window" affect.
	if _current_buffer.size() > target_sequence.size():
		_current_buffer.pop_front()
		
	if _current_buffer == target_sequence:
		sequence_matched.emit()
		if reset_on_match:
			_reset_buffer()

func _reset_buffer() -> void:
	_current_buffer.clear()
