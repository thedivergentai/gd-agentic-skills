class_name NetInterestManagement
extends Area3D

## Expert Interest Management (Network ROI).
## Toggles node visibility based on proximity to optimize bandwidth.

@export var synchronizer: MultiplayerSynchronizer
@export var cull_distance: float = 50.0

func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server(): return
	
	for peer_id in multiplayer.get_peers():
		var peer_node = get_tree().get_nodes_in_group("Players").filter(func(p): return p.name == str(peer_id))[0]
		var dist = global_position.distance_to(peer_node.global_position)
		
		synchronizer.set_visibility_for(peer_id, dist < cull_distance)

## Rule: Use interest management for large maps to prevent clients from receiving local data for players 1km away.
