# procedural_theme_safe.gd
# Ensuring safe theme lookups for procedurally generated UI [13]
extends PanelContainer

func _notification(what: int) -> void:
	# NOTIFICATION_THEME_CHANGED is the most reliable hook for 
	# dynamic theming as it catches tree entry and theme swaps.
	if what == NOTIFICATION_THEME_CHANGED:
		if not is_node_ready():
			await ready
			
		# Safely match a procedural element's color to the theme's core Button text
		var fallback_color := get_theme_color("font_color", "Button")
		$Label.add_theme_color_override("font_color", fallback_color)
