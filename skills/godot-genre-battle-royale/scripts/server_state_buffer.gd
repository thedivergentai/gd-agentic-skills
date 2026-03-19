# server_state_buffer.gd
# Handling UDP packet jitter on the server
extends Node

# EXPERT NOTE: UDP packets lack sequence guarantees. 
# Buffer and sort state chunks using IDs to prevent stutter.

var buffer: Dictionary = {}

func push_state(peer_id: int, state_id: int, data: Dictionary):
	if !buffer.has(peer_id): buffer[peer_id] = []
	buffer[peer_id].append({"id": state_id, "data": data})
	
	# Sort by ID to ensure sequential processing
	buffer[peer_id].sort_custom(func(a, b): return a.id < b.id)
