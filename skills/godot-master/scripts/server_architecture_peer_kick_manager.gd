# peer_kick_manager.gd
# Gracefully terminating peer connections
extends Node

# EXPERT NOTE: Disconnecting peers forcefully (disconnect_peer) 
# is cleaner than just erasing them from a list.

func remove_player(peer_id: int, reason: String):
	# Notify the peer first if possible
	_on_kicked.rpc_id(peer_id, reason)
	
	# Drop connection
	multiplayer.disconnect_peer(peer_id)
	print("Kicked peer ", peer_id, " for: ", reason)

@rpc("authority", "call_remote", "reliable")
func _on_kicked(reason: String):
	print("Disconnected by server: ", reason)
