# focus_navigation_manager.gd
# Enabling keyboard/gamepad-only menu navigation
extends Node

# EXPERT NOTE: Ensuring focus management is vital 
# for accessibility and keyboard-only classroom environments.

func set_initial_focus(container: Control):
	var first_btn = container.find_next_valid_focus()
	if first_btn:
		first_btn.grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# Escape key behavior for menu exits
		pass
