# crisp_ui_scaler.gd
# Resolution-independent UI scaling via content_scale_factor [18]
extends Node

func _ready() -> void:
	get_tree().root.size_changed.connect(_update_ui_scale)

func _update_ui_scale() -> void:
	var window_size := get_tree().root.size
	# Baseline is 1080p.
	# Scaling the factor instead of node.scale keeps fonts and styleboxes 
	# crisp and pixel-perfect at any resolution.
	var factor: float = window_size.y / 1080.0
	get_tree().root.content_scale_factor = factor
