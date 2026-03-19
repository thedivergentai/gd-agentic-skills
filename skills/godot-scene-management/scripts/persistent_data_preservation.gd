# persistent_data_preservation.gd
# Using an Autoload for scene-crossing variables [State Management]
extends Node

# EXPERT NOTE: Values in a Scene are lost when get_tree().change_scene is called. 
# Use a Singleton (Autoload) to keep state.

var player_hp: int = 100
var current_level_seed: int = 1234
var unlocked_items: Array = []

func save_state():
	# Logic to serialize variables to a config file
	pass
