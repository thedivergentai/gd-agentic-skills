# theme_swapper.gd
# Dynamic theme switching (Dark/Light mode) with cascading propagation
extends Node

@export var light_theme: Theme
@export var dark_theme: Theme

func set_dark_mode(is_dark: bool) -> void:
	# Find the root control (usually your main scene root)
	# Applying a theme at the root level updates all children automatically [11].
	var root_control := get_tree().root.get_child(0) as Control
	if root_control:
		root_control.theme = dark_theme if is_dark else light_theme
