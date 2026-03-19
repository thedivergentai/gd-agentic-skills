# item_slot_data.gd
# Data structure for a single inventory slot
class_name ItemSlot extends Resource

# EXPERT NOTE: Using a Resource for slots makes the 
# inventory system serializable and easy to sync with UI.

signal changed

@export var item: InventoryItem:
	set(val):
		item = val
		changed.emit()

@export var quantity: int = 1:
	set(val):
		quantity = val
		changed.emit()
