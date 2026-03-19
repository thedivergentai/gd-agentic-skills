# lazy_loaded_singleton.gd
# Creating "Autoloads" on demand to save memory
extends Node

# EXPERT NOTE: If a singleton is rarely used, don't put it in 
# Project Settings. Load it manually when needed.

static var _instance: Node = null

static func get_instance(tree: SceneTree) -> Node:
	if not is_instance_valid(_instance):
		_instance = load("res://systems/heavy_system.tscn").instantiate()
		tree.root.add_child(_instance)
	return _instance
