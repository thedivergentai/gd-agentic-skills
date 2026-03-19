# custom_debug_draw.gd
# Visualizing AI paths and physics bounds in 2D
extends Node2D

# EXPERT NOTE: Use _draw() to visualize non-visual data. 
# Redrawing every frame allows tracking moving targets.

var path: PackedVector2Array = []

func _draw():
	if not OS.is_debug_build(): return
	if path.size() < 2: return
	
	draw_polyline(path, Color.CYAN, 3.0, true)

func _process(_delta):
	queue_redraw()
