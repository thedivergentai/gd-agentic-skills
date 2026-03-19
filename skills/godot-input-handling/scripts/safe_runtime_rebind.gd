# safe_runtime_rebind.gd
# Safe runtime input rebinding with multi-device support [15, 16]
extends Node

# EXPERT NOTE: Always check for conflicts before applying a rebind. 
# Also, handle the case where a player binds a Joypad button to a keyboard action.

func rebind_action(action_name: String, new_event: InputEvent) -> bool:
	# 1. Check for conflicts
	for action in InputMap.get_actions():
		if action == action_name: continue
		if InputMap.action_has_event(action, new_event):
			printerr("Conflict: ", new_event.as_text(), " already bound to ", action)
			return false
	
	# 2. Apply rebind
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, new_event)
	
	# 3. Persistence (Save to ConfigFile)
	_save_rebinds()
	return true

func _save_rebinds():
	# Standard pattern: save to user://input.cfg
	pass
