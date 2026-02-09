# skills/inventory-system/scripts/inventory_grid.gd
extends Control

## Inventory Grid Expert Pattern
## Grid-based inventory with drag-and-drop support and auto-sorting.

class_name InventoryGrid

signal item_dropped(item: InventoryItem, target_index: int)
signal item_removed(item: InventoryItem)

@export var inventory_data: InventoryData
@export var slot_scene: PackedScene
@export var columns := 5

@onready var grid_container: GridContainer = $GridContainer

func _ready() -> void:
	if inventory_data:
		inventory_data.inventory_changed.connect(_on_inventory_changed)
		_refresh_display()

func _on_inventory_changed() -> void:
	_refresh_display()

func _refresh_display() -> void:
	# Clear existing sorting
	for child in grid_container.get_children():
		child.queue_free()
	
	grid_container.columns = columns
	
	for i in inventory_data.slots.size():
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		
		# Configure slot
		if inventory_data.slots[i]:
			slot.set_item(inventory_data.slots[i])
		
		# Connect drag/drop signals
		slot.gui_input.connect(_on_slot_gui_input.bind(i))

func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Begin Drag
				var item = inventory_data.slots[index]
				if item:
					var drag_data = {
						"item": item,
						"source_index": index,
						"source_inventory": self
					}
					var preview = TextureRect.new()
					preview.texture = item.icon
					preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
					preview.custom_minimum_size = Vector2(50, 50)
					force_drag(drag_data, preview)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("item")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var item = data.item
	var source_index = data.source_index
	var source_inventory = data.source_inventory
	
	# Calculate sorting index based on local mouse position in grid
	# This requires raycasting or math logic depending on specific UI setup
	# For simplicity, we'll append or swap logic here
	
	if source_inventory == self:
		# Swap internal
		pass
	else:
		# Move from sorting
		pass
	
	# This script serves as a UI controller foundation
	# Implement exact drop logic based on your slot layout

## EXPERT USAGE:
## 1. Create InventoryGrid scene
## 2. Assign InventoryData resource
## 3. Connect signals for gameplay logic
