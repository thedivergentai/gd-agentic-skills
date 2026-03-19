# harvest_inventory_manager.gd
# [GDSKILLS] godot-game-loop-harvest
# EXPORT_REFERENCE: harvest_inventory_manager.gd

extends Node

signal inventory_updated(resource_name: String, new_amount: int)

var inventory: Dictionary = {}

func add_resource(resource: HarvestResourceData, amount: int) -> void:
	var id = resource.display_name
	if not inventory.has(id):
		inventory[id] = 0
	
	inventory[id] += amount
	inventory_updated.emit(id, inventory[id])
	print("Harvested %d %s. Total: %d" % [amount, id, inventory[id]])

func get_resource_count(resource_name: String) -> int:
	return inventory.get(resource_name, 0)

func has_resources(resource_name: String, amount: int) -> bool:
	return get_resource_count(resource_name) >= amount

func consume_resource(resource_name: String, amount: int) -> bool:
	if not has_resources(resource_name, amount):
		return false
		
	inventory[resource_name] -= amount
	inventory_updated.emit(resource_name, inventory[resource_name])
	return true
