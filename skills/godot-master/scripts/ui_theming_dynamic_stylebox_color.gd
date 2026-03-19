# dynamic_stylebox_color.gd
# Safely overriding StyleBoxes at runtime without affecting other nodes [10]
extends Button

func set_runtime_color(new_color: Color) -> void:
	# CRITICAL: StyleBoxes are resources and SHARED by default.
	# You MUST duplicate() before modifying or you will change the whole theme.
	var custom_style := get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	
	if custom_style:
		custom_style.bg_color = new_color
		# Apply the unique override to this specific instance only
		add_theme_stylebox_override("normal", custom_style)
