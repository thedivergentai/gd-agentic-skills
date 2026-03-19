# subviewport_scene_layering.gd
# Running two different scenes in parallel using Viewports
extends SubViewportContainer

# EXPERT NOTE: Use SubViewports for Mini-maps, Split-screen, 
# or 3D UI elements rendered in a 2D world.

func _ready() -> void:
	# Ensure the viewport is correctly capturing its own world
	$SubViewport.own_world_3d = true
