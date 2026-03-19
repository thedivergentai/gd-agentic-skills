# secured_rpc_pattern.gd
# Communication between peers with authority checks
extends Node

# EXPERT NOTE: ALWAYS use any_peer or authority explicitly. 
# NEVER trust client data without server-side validation.

@rpc("any_peer", "call_remote", "reliable")
func request_player_action(action_id: String):
	# Only the server should process authoritative logic
	if not multiplayer.is_server(): return
	
	var sender_id = multiplayer.get_remote_sender_id()
	# Validate if player 'sender_id' can perform 'action_id'
	print("Server processing action from: ", sender_id)
	_broadcast_result.rpc(action_id)

@rpc("authority", "call_local", "reliable")
func _broadcast_result(action_id: String):
	# Everyone (including server itself) updates their local state
	pass
