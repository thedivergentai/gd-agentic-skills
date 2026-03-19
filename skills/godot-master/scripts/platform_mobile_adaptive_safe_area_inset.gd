class_name AdaptiveSafeAreaInset
extends Node

## Expert Safe Area handler for modern mobile notches and punch-holes.
## Automatically applies insets to UI margins based on DisplayServer data.

@export var target_control: Control

func _ready() -> void:
	get_viewport().size_changed.connect(_update_safe_area)
	_update_safe_area()

func _update_safe_area() -> void:
	if not target_control: return
	
	var safe_area := DisplayServer.get_display_safe_area()
	var screen_size := DisplayServer.screen_get_size()
	
	# Convert absolute safe area to relative offsets
	target_control.offset_top = safe_area.position.y
	target_control.offset_left = safe_area.position.x
	target_control.offset_bottom = -(screen_size.y - safe_area.end.y)
	target_control.offset_right = -(screen_size.x - safe_area.end.x)

## Rule: Always use safe-area insets for critical gameplay UI (Health, Menu buttons).
