# game_state_sync_manager.gd
# Master clock synchronization
extends Node

# EXPERT NOTE: Synchronizing game time between server and 
# clients is critical for deterministic physics or effects.

var server_time: float = 0.0

@rpc("authority", "call_remote", "unreliable")
func sync_time(time: float):
	server_time = time
