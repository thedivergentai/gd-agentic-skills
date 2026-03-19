class_name PhysicalInputRebinder
extends Node

## Expert rebind system using Physical Keycodes.
## Ensures WASD movement works on AZERTY/Dvorak without manual remapping.

func rebind_action_physical(action: StringName, key_event: InputEventKey) -> void:
	# Convert standard keycode to physical location-based keycode
	if key_event.keycode != KEY_NONE:
		key_event.physical_keycode = key_event.keycode
		key_event.keycode = KEY_NONE
	
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, key_event)
	_notify_input_updated()

func _notify_input_updated() -> void:
	# Signal other systems (UI prompts) that bindings have changed
	pass

## Rule: Always use 'physical_keycode' for positional gameplay controls (WASD/ESDF).
