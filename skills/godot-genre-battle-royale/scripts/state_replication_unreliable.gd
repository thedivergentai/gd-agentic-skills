# state_replication_unreliable.gd
# Synchronizing player transforms via unreliable streams
extends Node

# EXPERT NOTE: For 100 players, Reliable mode causes congestion. 
# ALWAYS use Unreliable/Unreliable Ordered for movement.

@rpc("authority", "call_remote", "unreliable")
func update_player_transform(p_id: int, pos: Vector3, rot: float):
	# Interpolate state on clients
	_on_peer_transform_sync(p_id, pos, rot)

func _on_peer_transform_sync(_id, _p, _r): pass
