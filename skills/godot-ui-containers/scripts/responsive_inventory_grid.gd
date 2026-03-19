# responsive_inventory_grid.gd
# Auto-adjusting GridContainer columns based on available width [10]
extends GridContainer

@export var item_min_width: float = 64.0

func _ready() -> void:
	# Recalculate layout whenever the window or container resizes
	resized.connect(_on_resized)

func _on_resized() -> void:
	var h_sep := get_theme_constant("h_separation")
	var available_width := size.x
	
	# Compute max columns that fit without manual overflow
	var max_cols := maxi(1, int((available_width + h_sep) / (item_min_width + h_sep)))
	columns = max_cols
