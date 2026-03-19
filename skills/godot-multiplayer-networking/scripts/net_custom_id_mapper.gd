class_name NetCustomIDMapper
extends Node

## Expert ID Mapping.
## Maps persistent DB UserIDs to ephemeral Network PeerIDs.

var peer_to_user: Dictionary = {}
var user_to_peer: Dictionary = {}

func register_player(peer_id: int, user_id: String) -> void:
	peer_to_user[peer_id] = user_id
	user_to_peer[user_id] = peer_id

func get_peer(user_id: String) -> int:
	return user_to_peer.get(user_id, -1)

## Rule: PeerIDs change on every reconnect; UserIDs are permanent. Mapping is mandatory.
