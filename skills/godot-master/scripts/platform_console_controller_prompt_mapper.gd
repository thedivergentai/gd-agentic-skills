class_name ControllerPromptMapper
extends RefCounted

## Expert GUID-based Icon Routing for Console UI.
## Detects hardware type to display correct button prompts (PS/Xbox/Switch).

static func get_prompt_path(device_id: int) -> String:
	var guid = Input.get_joy_guid(device_id)
	var name = Input.get_joy_name(device_id).to_lower()
	
	# Detect platform from standardized SDL2 identifiers
	if "nintendo" in name or "switch" in name:
		return "res://ui/prompts/nintendo_set.tres"
	elif "ps4" in name or "ps5" in name or "dual" in name:
		return "res://ui/prompts/playstation_set.tres"
	else:
		# Fallback to Xbox/XInput standard
		return "res://ui/prompts/xbox_set.tres"

## Rule: Always display SVG-based prompts for high-DPI console displays.
