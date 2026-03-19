# resource_based_inventory.gd
# Managing item collections using Resource arrays
class_name Inventory extends Resource

@export var items: Array[ItemData] = []

func add_item(item: ItemData):
	items.append(item)
	emit_changed()

func remove_item(item: ItemData):
	items.erase(item)
	emit_changed()
