# inventory_data_resource.gd
# Centralized inventory storage and logic
class_name InventoryData extends Resource

# EXPERT NOTE: Move all logic into the Resource to make it 
# decoupled from any specific Node (Player vs Chest).

signal inventory_updated

@export var slots: Array[ItemSlot] = []

func add_item(new_item: InventoryItem, count: int = 1) -> bool:
	# 1. Try to stack
	if new_item.stackable:
		for slot in slots:
			if slot.item == new_item and slot.quantity < new_item.max_stack:
				slot.quantity += count
				inventory_updated.emit()
				return true
				
	# 2. Find empty slot
	for i in range(slots.size()):
		if slots[i].item == null:
			var new_slot = ItemSlot.new()
			new_slot.item = new_item
			new_slot.quantity = count
			slots[i] = new_slot
			inventory_updated.emit()
			return true
			
	return false

func remove_at(index: int):
	slots[index].item = null
	slots[index].quantity = 0
	inventory_updated.emit()
