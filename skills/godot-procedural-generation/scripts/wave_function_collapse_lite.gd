# wave_function_collapse_lite.gd
# Procedural tile arrangement using WFC principles
extends Node

# EXPERT NOTE: WFC is excellent for city generation or 
# complex level layouts where tiles must obey adjacency rules.

var entropy_map: Array = []

func iterate():
	# 1. Find cell with lowest entropy
	# 2. Collapse it to a random valid state
	# 3. Propagate changes to neighbors
	pass
func propagate(_x, _y): pass
func collapse(_x, _y): pass
func find_lowest_entropy(): return Vector2i.ZERO
