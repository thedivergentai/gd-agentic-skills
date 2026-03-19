# danger_button_assignment.gd
# Using Theme Variations to create specialized styles without custom scenes [12]
extends Button

func _ready() -> void:
	# Assigning a StringName tells the node to look for this variation
	# in the active Theme. If found, it uses those overrides; otherwise,
	# it falls back to the base "Button" style.
	theme_type_variation = &"DangerButton"
