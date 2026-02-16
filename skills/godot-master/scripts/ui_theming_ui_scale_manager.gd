# godot-master/scripts/ui_theming_ui_scale_manager.gd
extends Node

## UI Scale & Theme Manager Expert Pattern
## Global management of UI scaling and theme swapping.

class_name UIScaleManager

signal scale_changed(new_scale: float)
signal theme_changed(new_theme_resource: Theme)

@export var base_resolution := Vector2i(1920, 1080)
@export var min_scale := 0.5
@export var max_scale := 2.0

var _current_scale := 1.0

func _ready() -> void:
	get_tree().root.size_changed.connect(_update_scale)
	_update_scale()

func set_theme(theme_path: String) -> void:
	var new_theme = load(theme_path) as Theme
	if new_theme:
		get_tree().root.theme = new_theme
		theme_changed.emit(new_theme)
	else:
		push_error("Failed to load theme: %s" % theme_path)

func _update_scale() -> void:
	var window = get_window()
	var current_res = window.size
	
	# Calculate scale based on width ratio (or height, depending on preference)
	var scale_factor = float(current_res.x) / float(base_resolution.x)
	scale_factor = clampf(scale_factor, min_scale, max_scale)
	
	if not is_equal_approx(scale_factor, _current_scale):
		_current_scale = scale_factor
		_apply_scale(scale_factor)
		scale_changed.emit(scale_factor)

func _apply_scale(scale_factor: float) -> void:
	# Method 1: Content Scale Factor (Godot 4 native)
	get_window().content_scale_factor = scale_factor
	
	# Method 2: Manual Control scaling (if not using Stretch Mode: Canvas Items)
	# This usually iterates over root UI nodes if you need manual control
	# var root_control = get_tree().current_scene.get_node_or_null("UI")
	# if root_control:
	# 	root_control.scale = Vector2.ONE * scale_factor

## EXPERT USAGE:
## Autoload this script as 'UIManager'.
## UIManager.set_theme("res://themes/dark_mode.tres")
## Connect to scale_changed for custom widget adjustments.
