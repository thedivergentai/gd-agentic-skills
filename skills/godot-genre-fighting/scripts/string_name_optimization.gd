# string_name_optimization.gd
# Speeding up move-lookups via hashed strings
extends Node

# EXPERT NOTE: Use StringName (&"name") for high-frequency 
# lookups. It uses an internal hash for near O(1) matching.

var move_set: Dictionary = {
	&"punch": 10,
	&"kick": 15
}

func execute_move(move_name: StringName):
	if move_set.has(move_name):
		print("Executing ", move_name)
