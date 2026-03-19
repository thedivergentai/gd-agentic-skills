# raw_byte_network_sync.gd
# Bypassing RPCs for low-level rollback UDP packets
extends Node

# EXPERT NOTE: send_bytes() with UNRELIABLE mode is the 
# fastest way to transmit raw input frames.

func send_input_frame(frame_data: PackedByteArray):
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.put_packet(frame_data)

func _on_packet_received(data: PackedByteArray):
	# Parse raw bytes directly into the rollback buffer
	_handle_input_data(data)

func _handle_input_data(_d): pass
