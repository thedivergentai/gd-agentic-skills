# l_system_tree_gen.gd
# Procedural tree/plant growth using L-Systems
extends Node3D

# Turtle graphics approach to plant generation.

func draw_lsystem(axiom: String, rules: Dictionary, iterations: int):
	var current = axiom
	for i in range(iterations):
		var next = ""
		for char in current:
			next += rules.get(char, char)
		current = next
	# Then iterate characters to draw lines/branches
	return current
