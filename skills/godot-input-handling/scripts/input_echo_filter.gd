# input_echo_filter.gd
# Filtering echo events for UI navigation vs Gameplay
extends Control

# EXPERT NOTE: InputEvent.is_echo() is true for auto-repeated keys.
# Never trigger gameplay actions on echo, but always allow UI movement.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if event.is_echo():
			# Ignore hold-to-confirm if that's not desired
			return
		_do_confirm()

func _do_confirm():
	print("Confirmed!")
