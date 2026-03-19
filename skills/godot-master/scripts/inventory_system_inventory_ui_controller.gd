# inventory_ui_controller.gd
# Mapping data to visual representations
extends GridContainer

# EXPERT NOTE: The UI should listen to the Data Resource. 
# This is the "Reactive UI" pattern.

@export var inventory_data: InventoryData

func _ready():
	if inventory_data:
		inventory_data.inventory_updated.connect(_on_inventory_updated)
		_render_inventory()

func _render_inventory():
	for child in get_children():
		child.queue_free()
		
	for slot in inventory_data.slots:
		var slot_ui = preload("res://ui/inventory_slot.tscn").instantiate()
		add_child(slot_ui)
		slot_ui.set_slot_data(slot)

func _on_inventory_updated():
	_render_inventory()
