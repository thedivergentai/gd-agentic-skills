# godot-master/scripts/ui_containers_responsive_grid.gd
extends GridContainer

## Responsive Grid Expert Pattern
## Automatically adjusts columns based on container width and item min_size.

class_name ResponsiveGrid

@export var min_item_width := 100.0
@export var max_columns := 10
@export var keep_square_ratio := false

func _ready() -> void:
	resized.connect(_on_resized)
	sort_children.connect(_on_sort_children)
	_recalculate_layout()

func _on_resized() -> void:
	_recalculate_layout()

func _on_sort_children() -> void:
	_recalculate_layout()

func _recalculate_layout() -> void:
	if size.x == 0:
		return
		
	var available_width := size.x
	var h_sep := get_theme_constant("h_separation")
	
	# Calculate how many items fit
	var tentative_cols := floori((available_width + h_sep) / (min_item_width + h_sep))
	tentative_cols = clampi(tentative_cols, 1, max_columns)
	
	if columns != tentative_cols:
		columns = tentative_cols
	
	# Optional: Enforce square aspect ratio on children if they expand
	if keep_square_ratio:
		_enforce_square_ratio()

func _enforce_square_ratio() -> void:
	var item_width := (size.x - (columns - 1) * get_theme_constant("h_separation")) / columns
	
	for child in get_children():
		if child is Control and not child.is_queued_for_deletion():
			child.custom_minimum_size.y = item_width

## EXPERT USAGE:
## 1. Attach to a GridContainer
## 2. Set Min Item Width (e.g., 150px)
## 3. Set Children Size Flags to Expand (Horizontal)
## Result: Grid flows from 1 to N columns automatically as window resizes.
