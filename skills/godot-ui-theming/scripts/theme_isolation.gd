# theme_isolation.gd
# Forcing a node to ignore parent themes and use the Project default [15]
extends Control

func _ready() -> void:
	# If a parent customizes the theme, but this HUD needs absolute consistency:
	var baseline_theme := ThemeDB.get_project_theme()
	
	# Explicitly setting the theme resource halts the upward tree search.
	# This ensures the HUD pulls only from the Project Settings theme.
	self.theme = baseline_theme
