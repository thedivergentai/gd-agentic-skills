class_name EasterPaletteOverride
extends Node

## Applies an Easter Pastel palette to all child Control nodes.
## Useful for instantly "Spring-ifying" a UI menu.

# The Palette
const COLOR_PINK = Color("FFC1CC")
const COLOR_CYAN = Color("E0FFFF")
const COLOR_YELLOW = Color("FFFFE0")
const COLOR_MINT = Color("98FF98")

@export var target_root: Control
@export var apply_on_ready: bool = true

func _ready() -> void:
	if apply_on_ready:
		apply_theme()

func apply_theme() -> void:
	var root = target_root if target_root else get_parent()
	if not root is Control:
		return
		
	_apply_to_node_recursive(root)

func _apply_to_node_recursive(node: Node) -> void:
	if node is Panel:
		_override_stylebox(node, "panel", COLOR_PINK)
	elif node is Button:
		_override_stylebox(node, "normal", COLOR_CYAN)
		_override_stylebox(node, "hover", COLOR_YELLOW)
		_override_stylebox(node, "pressed", COLOR_MINT)
	elif node is Label:
		node.add_theme_color_override("font_color", Color.WHITE)
		node.add_theme_color_override("font_outline_color", COLOR_PINK)
		node.add_theme_constant_override("outline_size", 4)

	for child in node.get_children():
		_apply_to_node_recursive(child)

func _override_stylebox(control: Control, theme_item: String, color: Color) -> void:
	# We try to get the existing stylebox to preserve borders/radius
	# If it's a StyleBoxFlat, we copy it. If not, we make a new one.
	var existing = control.get_theme_stylebox(theme_item)
	var new_style: StyleBoxFlat
	
	# Crucial: We must duplicate the stylebox to avoid modifying the global theme
	if existing is StyleBoxFlat:
		new_style = existing.duplicate()
	else:
		new_style = StyleBoxFlat.new()
		# Set some sensible defaults if we're creating from scratch
		new_style.set_corner_radius_all(8)
	
	new_style.bg_color = color
	control.add_override(theme_item, new_style)
