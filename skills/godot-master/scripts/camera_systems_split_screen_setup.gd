# split_screen_setup.gd
# Managing dynamic split-screen viewports efficiently [146]
extends HBoxContainer

# Scene Structure:
# HBoxContainer
#   ├─ SubViewportContainer (Player 1)
#   │   └─ SubViewport
#   │       └─ Camera2D
#   └─ SubViewportContainer (Player 2)
#       └─ SubViewport
#           └─ Camera2D

func set_split_ratio(ratio: float) -> void:
	# Custom weight management for asymmetric split-screen
	var p1 = get_child(0) as Control
	var p2 = get_child(1) as Control
	
	p1.size_flags_stretch_ratio = ratio
	p2.size_flags_stretch_ratio = 1.0 - ratio

func _ready() -> void:
	# Ensure audio listeners are balanced
	get_child(0).get_node("SubViewport").audio_listener_enable_2d = true
	get_child(1).get_node("SubViewport").audio_listener_enable_2d = false
