# deadzone_drag_margins.gd
# Platformer-style deadzone management in code [267]
extends Camera2D

func _ready() -> void:
	# Enables the 'drag' margins that define a central deadzone
	drag_horizontal_enabled = true
	drag_vertical_enabled = true
	
	# Margin 0.2 means the player must move 20% from center 
	# before the camera starts following.
	drag_left_margin = 0.2
	drag_right_margin = 0.2
	drag_top_margin = 0.4
	drag_bottom_margin = 0.1
	
	# Visualizes the deadzone in the editor
	editor_draw_drag_margin = true
