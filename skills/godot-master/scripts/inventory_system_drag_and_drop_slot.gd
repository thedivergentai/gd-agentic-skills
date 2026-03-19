# drag_and_drop_slot.gd
# Implementing native Godot drag & drop for inventory
extends PanelContainer

# EXPERT NOTE: Using Godot's built-in drag/drop methods 
# ensures consistent behavior and cross-platform support.

var slot_data: ItemSlot

func _get_drag_data(_at_position: Vector2) -> Variant:
	if slot_data.item == null: return null
	
	var preview = TextureRect.new()
	preview.texture = slot_data.item.icon
	set_drag_preview(preview)
	
	return slot_data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ItemSlot

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var dropped_slot = data as ItemSlot
	# Swap logic goes here
	# (e.g. notify inventory_data to swap indices)
