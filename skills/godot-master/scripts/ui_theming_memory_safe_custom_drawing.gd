# memory_safe_custom_drawing.gd
# Preventing garbage collection of StyleBoxes during _draw() [7]
extends Control

# CRITICAL: If you create a StyleBox inside _draw(), it will be 
# garbage collected before the RenderingServer can use it.
# ALWAYS cache styleboxes used for draw_style_box at the class level.
var _persistent_style: StyleBoxFlat

func _ready() -> void:
	_persistent_style = StyleBoxFlat.new()
	_persistent_style.bg_color = Color.MEDIUM_SLATE_BLUE
	_persistent_style.corner_radius_all = 8

func _draw() -> void:
	draw_style_box(_persistent_style, Rect2(Vector2.ZERO, size))
