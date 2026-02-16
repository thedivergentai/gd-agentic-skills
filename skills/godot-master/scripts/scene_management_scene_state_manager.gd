# godot-master/scripts/scene_management_scene_state_manager.gd
extends Node

## Scene State Manager Expert Pattern
## Preserves and restores scene state across transitions (player position, collected items, NPC states).

class_name SceneStateManager

var _scene_states: Dictionary = {}  # scene_path → state data

func save_current_scene() -> void:
	var current_scene := get_tree().current_scene
	if not current_scene:
		return
		
	var scene_path := current_scene.scene_file_path
	var state := {}
	
	# Save all nodes in "persist" group
	for node in get_tree().get_nodes_in_group("persist"):
		var node_data := {}
		
		if node is Node2D or node is Node3D:
			node_data["position"] = node.global_position
			
		if node.has_method("save_state"):
			node_data["custom"] = node.save_state()
			
		state[node.get_path()] = node_data
	
	_scene_states[scene_path] = state
	print("Saved state for: %s (%d nodes)" % [scene_path, state.size()])

func restore_scene(scene_path: String) -> void:
	if scene_path not in _scene_states:
		return
		
	await get_tree().process_frame  # Wait for scene to load
	
	var state: Dictionary = _scene_states[scene_path]
	
	for node_path in state:
		var node := get_tree().current_scene.get_node_or_null(node_path)
		if not node:
			continue
			
		var node_data: Dictionary = state[node_path]
		
		if "position" in node_data:
			node.global_position = node_data["position"]
			
		if "custom" in node_data and node.has_method("load_state"):
			node.load_state(node_data["custom"])
	
	print("Restored state for: %s (%d nodes)" % [scene_path, state.size()])

func clear_scene_state(scene_path: String) -> void:
	_scene_states.erase(scene_path)

func clear_all_states() -> void:
	_scene_states.clear()

## EXPERT USAGE:
## Add nodes to "persist" group + implement save_state/load_state:
##
## func save_state() -> Dictionary:
##   return {"health": health, "inventory": inventory}
##
## func load_state(data: Dictionary) -> void:
##   health = data.get("health", 100)
##   inventory = data.get("inventory", [])
