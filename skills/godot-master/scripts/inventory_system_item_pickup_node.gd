# item_pickup_node.gd
# World-to-Inventory bridge
extends Area2D

@export var item_data: InventoryItem
@export var count: int = 1

func _on_body_entered(body: Node2D):
	if body.has_method("get_inventory"):
		var inv = body.get_inventory() as InventoryData
		if inv.add_item(item_data, count):
			queue_free()
