# marching_squares_metaballs.gd
# Smooth contour generation (Marching Squares algorithm)
extends Node

# EXPERT NOTE: Use Marching Squares for organic-looking terrains, 
# liquid simulations, or influence maps.

func get_contour_index(tl: float, tr: float, br: float, bl: float, threshold: float) -> int:
	var index = 0
	if tl >= threshold: index |= 8
	if tr >= threshold: index |= 4
	if br >= threshold: index |= 2
	if bl >= threshold: index |= 1
	return index
