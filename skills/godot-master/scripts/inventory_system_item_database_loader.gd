# item_database_loader.gd
# Global item registry pattern
extends Node

# EXPERT NOTE: Pre-assigning unique IDs to items allows 
# the save system to store IDs instead of full resources.

var items: Dictionary = {}

func _ready():
	var dir = DirAccess.open("res://items/")
	dir.list_dir_begin()
	var filename = dir.get_next()
	while filename != "":
		if filename.ends_with(".tres"):
			var item = load("res://items/" + filename) as InventoryItem
			items[item.id] = item
		filename = dir.get_next()

func get_item(id: String) -> InventoryItem:
	return items.get(id)
