# card_drag_drop.gd
# Native Control node drag-and-drop implementation
extends Control

# EXPERT NOTE: Using Godot's built-in drag API ensures 
# consistency and handles OS-level cursor and window events.

func _get_drag_data(_at_position: Vector2):
	var preview = Label.new()
	preview.text = name
	set_drag_preview(preview)
	return self # Pass card data or node to the drop target

func _can_drop_data(_pos: Vector2, _data):
	return _data is Control # Basic validation
