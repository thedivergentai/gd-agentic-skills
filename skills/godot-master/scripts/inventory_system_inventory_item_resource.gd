# inventory_item_resource.gd
# Base Resource for all inventory items
class_name InventoryItem extends Resource

# EXPERT NOTE: Defining item properties in a Resource allows 
# for creating .tres database files.

@export var id: String = ""
@export var name: String = "New Item"
@export var icon: Texture2D
@export var stackable: bool = false
@export var max_stack: int = 99
@export_multiline var description: String = ""

func use(_actor: Node) -> void:
	# Virtual method for item behavior
	pass
