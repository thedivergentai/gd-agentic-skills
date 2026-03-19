# authoritative_looting.gd
# Server-side validation for item collection
extends Node

# EXPERT NOTE: Trust the Server. If a client "loots" an item, 
# the server must verify proximity and item existence.

@rpc("any_peer", "call_local", "reliable")
func request_loot(loot_id: String):
	if not multiplayer.is_server(): return
	
	var sender_id = multiplayer.get_remote_sender_id()
	if _verify_looting(sender_id, loot_id):
		_distribute_loot(sender_id, loot_id)

func _verify_looting(_id, _item): return true
func _distribute_loot(_id, _item): pass
