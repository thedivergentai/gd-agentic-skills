# server_authority_validator.gd
# Validating client requests at the entry point
extends Node

# EXPERT NOTE: RPC authority checks are the first line of defense. 
# Use get_remote_sender_id() to identify and validate peers.

@rpc("any_peer", "call_local", "reliable")
func commit_transaction(item_id: String, amount: int):
	if not multiplayer.is_server(): return
	
	var peer_id = multiplayer.get_remote_sender_id()
	if _can_afford(peer_id, amount):
		_apply_transaction(peer_id, item_id, amount)
	else:
		_notify_error.rpc_id(peer_id, "Insufficient funds")

@rpc("authority", "call_remote", "reliable")
func _notify_error(msg: String): pass

func _can_afford(id, amt): return true
func _apply_transaction(id, item, amt): pass
