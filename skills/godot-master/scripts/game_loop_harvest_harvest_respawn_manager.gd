# harvest_respawn_manager.gd
# [GDSKILLS] godot-game-loop-harvest
# EXPORT_REFERENCE: harvest_respawn_manager.gd

extends Node
## Global Registry for managing depleted resource nodes.
## This is an "Open World" persistence pattern for harvesting.

signal node_respawned(node: Node)

## Tracking of nodes currently depleted and their remaining respawn time.
var _depleted_nodes: Array[Dictionary] = []

func register_depletion(node: Node3D, respawn_time: float) -> void:
	# Store reference and time
	var depletion_info = {
		"node": node,
		"respawn_at": Time.get_ticks_msec() + (respawn_time * 1000)
	}
	_depleted_nodes.append(depletion_info)
	
	# Node-specific handling (e.g., hiding and disabling collision)
	node.collision_layer = 1 << 15 # Layer 16 (Inactive)
	node.hide()

func _process(_delta: float) -> void:
	var current_time = Time.get_ticks_msec()
	
	# Process respawns
	var i = _depleted_nodes.size() - 1
	while i >= 0:
		var node_info = _depleted_nodes[i]
		if current_time >= node_info.respawn_at:
			_respawn_node(node_info.node)
			_depleted_nodes.remove_at(i)
		i -= 1

func _respawn_node(node: Node3D) -> void:
	if node.has_method("respawn"):
		node.respawn()
	else:
		node.collision_layer = 1 << 0 # Layer 1 (World)
		node.show()
	node_respawned.emit(node)
