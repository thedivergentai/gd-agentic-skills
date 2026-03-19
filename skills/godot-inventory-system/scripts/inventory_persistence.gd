# inventory_persistence.gd
# Saving and loading complex inventory structures
extends Node

@export var inventory: InventoryData

func save_to_file(path: String):
	# Serializing the entire Resource tree automatically
	var err = ResourceSaver.save(inventory, path)
	if err != OK:
		push_error("Inventory save failed: ", err)

func load_from_file(path: String):
	if ResourceLoader.exists(path):
		inventory = load(path)
