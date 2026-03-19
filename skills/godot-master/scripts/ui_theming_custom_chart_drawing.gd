# custom_chart_drawing.gd
# Reading theme properties for custom _draw() calls [14]
extends Control

func _draw() -> void:
	# Respect the active Theme even in custom drawing logic
	var accent := get_theme_color("accent_color", "CustomChart")
	var ui_font := get_theme_font("font", "Label")
	var ui_size := get_theme_font_size("font_size", "Label")
	var style := get_theme_stylebox("panel", "PanelContainer")
	
	# Draw background using the theme's panel style
	draw_style_box(style, Rect2(Vector2.ZERO, size))
	
	# Draw custom data visualization using theme colors
	draw_circle(size / 2.0, 20.0, accent)
	draw_string(ui_font, Vector2(10, size.y - 10), "Themed Label", HORIZONTAL_ALIGNMENT_LEFT, -1, ui_size)
