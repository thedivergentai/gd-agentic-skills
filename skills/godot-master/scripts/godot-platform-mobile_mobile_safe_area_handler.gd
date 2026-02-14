# skills/platform-mobile/scripts/mobile_safe_area_handler.gd
extends Control

## Mobile Safe Area Handler Expert Pattern
## Dynamic UI Adjuster for notches, punch-holes, and rounded corners.

class_name MobileSafeAreaHandler

enum Side { SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM }

@export_group("References")
@export var left_margin: Control
@export var right_margin: Control
@export var top_margin: Control
@export var bottom_margin: Control

@export_group("Layout")
@export var extra_padding: int = 0 # Extra safety padding in pixels

func _ready() -> void:
	# Monitor for orientation changes
	get_tree().root.size_changed.connect(_update_margins)
	# Initial update
	_update_margins()

func _update_margins() -> void:
	var safe_area = DisplayServer.get_display_safe_area()
	var screen_size = DisplayServer.screen_get_size()
	
	# Calculate offsets based on safe area rect relative to screen
	var top_offset = safe_area.position.y
	var left_offset = safe_area.position.x
	var right_offset = screen_size.x - (safe_area.position.x + safe_area.size.x)
	var bottom_offset = screen_size.y - (safe_area.position.y + safe_area.size.y)
	
	# Apply to UI containers or margins if assigned
	if top_margin:
		_apply_margin(top_margin, Side.SIDE_TOP, top_offset)
	if bottom_margin:
		_apply_margin(bottom_margin, Side.SIDE_BOTTOM, bottom_offset)
	if left_margin:
		_apply_margin(left_margin, Side.SIDE_LEFT, left_offset)
	if right_margin:
		_apply_margin(right_margin, Side.SIDE_RIGHT, right_offset)

func _apply_margin(node: Control, side: Side, offset: float) -> void:
	# Only apply if offset is significant (e.g. > 0)
	if offset > 0:
		var total = offset + extra_padding
		match side:
			Side.SIDE_TOP, Side.SIDE_BOTTOM:
				node.custom_minimum_size.y = total
			Side.SIDE_LEFT, Side.SIDE_RIGHT:
				node.custom_minimum_size.x = total
	else:
		# Reset if no notch
		match side:
			Side.SIDE_TOP, Side.SIDE_BOTTOM:
				node.custom_minimum_size.y = 0
			Side.SIDE_LEFT, Side.SIDE_RIGHT:
				node.custom_minimum_size.x = 0

## EXPERT USAGE:
## Attach to a root Control. Assign margin containers (ColorRects or empty Controls) 
## that push your main UI content inward.
