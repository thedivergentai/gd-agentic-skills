class_name EasterRuntimeUIThemer
extends Node

## Expert runtime theme injector for mass UI customization.
## Iterates through the scene tree and applies pastel aesthetics.

const PASTEL_PINK = Color("#FFC1CC")
const PASTEL_MINT = Color("#98FF98")

func apply_easter_theme(root_node: Node) -> void:
	for child in root_node.get_children():
		if child is Button:
			_theme_button(child)
		elif child is Panel:
			_theme_panel(child)
		
		# Recursive injection
		apply_easter_theme(child)

func _theme_button(btn: Button) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = PASTEL_PINK
	style.set_corner_radius_all(12)
	style.border_width_bottom = 4
	style.border_color = Color.WHITE
	
	btn.add_theme_stylebox_override("normal", style)

## Rule: Always 'duplicate()' or create 'new()' StyleBoxes to avoid global leakage.
