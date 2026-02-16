# godot-master/scripts/ui_theming_global_theme_manager.gd
extends Node

## UI Theming Expert Pattern
## Implements Global Theme Architecture and Runtime Skin Swapping.

@export var light_theme: Theme
@export var dark_theme: Theme

# 1. Runtime Skin Swapping
func set_theme_mode(is_dark: bool) -> void:
	# Professional protocol: Apply theme to the root to cascade to all nodes.
	var target_theme = dark_theme if is_dark else light_theme
	
	# Option A: Global Theme (Godot 4 property)
	# This affects every UI node in the project instantly.
	# ThemeDB.set_project_theme(target_theme) # Generic Godot 4 approach
	
	# Option B: Root Scene Hand-off
	get_tree().root.theme = target_theme
	
	print("UI Theme swapped to: ", "Dark" if is_dark else "Light")

# 2. Theme Variation Logic
func apply_button_variant(button: Button, variant_name: String) -> void:
	# Professional protocol: Use 'theme_type_variation' to swap styles 
	# (e.g. PrimaryButton vs DangerButton) without manual hacking.
	button.theme_type_variation = variant_name

# 3. StyleBox Nine-Patch Mastery
func create_custom_panel() -> StyleBoxFlat:
	# Expert logic: Programmatically define a StyleBox with proper 
	# anti-aliasing and corner radii for high-end UI.
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.1, 0.1, 1.0)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_detail = 12
	sb.anti_aliasing = true
	return sb

## EXPERT NOTE:
## Use 'Theme Type Variations': Create a variation called 'HeaderLabel' 
## in your .theme file. Apply it to specific Label nodes to change 
## their font size globally without creating separate Label scenes.
## For 'ui-theming', implement 'Color Palettes as Constants': 
## Define a 'Colors' static class for shared hex codes to ensure 
## code-generated UI matches your .theme files perfectly.
## NEVER use 'Theme Overrides' on individual nodes for global styling; 
## use the '.theme' resource. Overrides are for 1-off exceptions 
## and make global visual updates impossible.
## Use 'NinePatchRect' or 'StyleBoxTexture' for complex UI borders 
## to prevent blurring when boxes are resized.
