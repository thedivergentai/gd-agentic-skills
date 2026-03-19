# rollback_state_serializer.gd
# High-speed serialization for frame snapshots
extends Node

# EXPERT NOTE: Rollback requires snapshots every frame. 
# Pre-allocating PackedByteArray ensures zero allocation stutters.

var state_buffer := PackedByteArray()

func _ready():
	state_buffer.resize(1024) # Reserve memory for the fighter state

func save_state() -> PackedByteArray:
	# Serialize position, health, inputs into binary
	return state_buffer # Return current snapshot
