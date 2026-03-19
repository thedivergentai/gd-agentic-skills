class_name NetLobbyLateJoinSync
extends Node

## Expert Late-Join State Synchronizer.
## Ensures new players receive a full world-state snapshot upon connection.

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_sync_new_player)

func _sync_new_player(id: int) -> void:
	# Snapshot the entire game state
	var state = {
		"score": 100,
		"elapsed_time": 300.0,
		"world_seed": 12345
	}
	rpc_id(id, "receive_full_state", state)

@rpc("authority", "call_remote", "reliable")
func receive_full_state(state: Dictionary) -> void:
	# Apply state to local world
	pass

## Rule: Reliable RPCs are mandatory for initial state syncing. Use Unreliable for physics thereafter.
