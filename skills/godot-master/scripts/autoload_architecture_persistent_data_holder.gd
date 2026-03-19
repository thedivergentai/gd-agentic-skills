# persistent_data_holder.gd
# Keeping data alive across scene changes
extends Node

# EXPERT NOTE: Values in Autoloads survive SceneTree.change_scene_to_file().
# Use for player inventory, settings, and quest progress.

var inventory: Array[String] = []
var settings: Dictionary = {"volume": 0.8, "fullscreen": false}

func add_item(item: String):
	inventory.append(item)
	print("Items persistent: ", inventory)
