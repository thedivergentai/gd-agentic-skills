# skills/input-handling/scripts/input_remapper.gd
extends Node

## Input Remapper Expert Pattern
## Runtime input rebinding with conflict detection and persistence.

class_name InputRemapper

const CONFIG_PATH := "user://input_bindings.cfg"

func rebind_action(action_name: String, new_event: InputEvent) -> bool:
	# Check for conflicts
	for existing_action in InputMap.get_actions():
		if existing_action == action_name:
			continue
		for event in InputMap.action_get_events(existing_action):
			if _events_match(event, new_event):
				push_warning("Input conflict: %s already bound to %s" % [new_event, existing_action])
				return false
	
	# Clear existing binding
	InputMap.action_erase_events(action_name)
	
	# Add new binding
	InputMap.action_add_event(action_name, new_event)
	
	return true

func save_bindings() -> void:
	var config := ConfigFile.new()
	
	for action in InputMap.get_actions():
		var events := InputMap.action_get_events(action)
		if events.size() > 0:
			config.set_value("bindings", action, _serialize_events(events))
	
	config.save(CONFIG_PATH)

func load_bindings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
		
	for action in config.get_section_keys("bindings"):
		var event_data = config.get_value("bindings", action)
		var events := _deserialize_events(event_data)
		
		InputMap.action_erase_events(action)
		for event in events:
			InputMap.action_add_event(action, event)

func _events_match(event_a: InputEvent, event_b: InputEvent) -> bool:
	if event_a.get_class() != event_b.get_class():
		return false
		
	if event_a is InputEventKey:
		return event_a.keycode == (event_b as InputEventKey).keycode
	elif event_a is InputEventMouseButton:
		return event_a.button_index == (event_b as InputEventMouseButton).button_index
	elif event_a is InputEventJoypadButton:
		return event_a.button_index == (event_b as InputEventJoypadButton).button_index
	
	return false

func _serialize_events(events: Array) -> Array:
	var result := []
	for event in events:
		result.append(var_to_str(event))
	return result

func _deserialize_events(data: Array) -> Array:
	var result := []
	for event_str in data:
		result.append(str_to_var(event_str))
	return result

## EXPERT USAGE:
## InputRemapper.load_bindings()  # In autoload _ready()
## InputRemapper.rebind_action("jump", event)
## InputRemapper.save_bindings()
