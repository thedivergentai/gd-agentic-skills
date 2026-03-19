class_name NetAntiDesyncReconciler
extends Node

## Expert Anti-Desync Reconciliation.
## Snap-corrects peers if they deviate too far from their server-side ghost instance.

@export var error_tolerance: float = 0.5 

func validate_peer_state(peer_id: int, reported_pos: Vector3) -> void:
	var shadow_pos = ServerGameState.get_peer_pos(peer_id)
	if reported_pos.distance_to(shadow_pos) > error_tolerance:
		# Force Correction RPC
		force_sync.rpc_id(peer_id, shadow_pos)

@rpc("authority", "reliable")
func force_sync(correct_pos: Vector3) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	player.global_position = correct_pos

## Rule: Snap-correction should be the LAST resort. Use interpolation/prediction first.
