class_name VRInputActionMapper
extends Node

## Expert OpenXR Action Map abstraction boilerplate.
## Decouples gameplay logic from specific controller button strings.

func _on_left_controller_input_event(name: String, _input_value: Variant) -> void:
	# Standard OpenXR action names from project settings
	match name:
		"grab":
			_on_grab()
		"teleport":
			_on_teleport_requested()

func _on_grab() -> void:
	pass

func _on_teleport_requested() -> void:
	pass

## Rule: Never hardcode controller strings; use the Action Map system.
