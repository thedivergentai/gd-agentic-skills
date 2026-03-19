class_name SecretSequenceComboMatcher
extends Node

## Expert Time-Sensitive Combo Matcher.
## Handles complex input sequences with a decay timer to prevent brute-forcing.

signal combo_achieved(combo_name: String)

@export var sequences: Dictionary = {"Konami": ["ui_up", "ui_up", "ui_down", "ui_down", "ui_left", "ui_right", "ui_left", "ui_right"]}
@export var input_timeout: float = 0.5

var current_buffer: Array[String] = []
var last_input_time: float = 0.0

func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	
	for action in InputMap.get_actions():
		if event.is_action_pressed(action):
			_add_to_buffer(action)

func _add_to_buffer(action: String) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_input_time > input_timeout:
		current_buffer.clear()
	
	current_buffer.append(action)
	last_input_time = current_time
	_check_matches()

func _check_matches() -> void:
	for combo_name in sequences:
		var target = sequences[combo_name]
		if current_buffer == target:
			combo_achieved.emit(combo_name)
			current_buffer.clear()

## Rule: Always clear the buffer on a successful match to prevent double-procs.
