# autoload_reference_checker.gd
# Validating singleton availability before access
extends Node

# EXPERT NOTE: Using 'get_node("/root/Name")' is safer than using the 
# global name if you code for packages/plugins that might lack the Autoload.

static func get_events(tree: SceneTree) -> Node:
	var path = "/root/GlobalEvents"
	if tree.root.has_node(path):
		return tree.root.get_node(path)
	push_warning("GlobalEvents Autoload not found!")
	return null
