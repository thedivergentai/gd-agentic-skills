# drunknard_walk_path.gd
# Simple path generation for dungeons or rivers
extends Node

func generate_path(start: Vector2i, steps: int) -> Array[Vector2i]:
	var current = start
	var path: Array[Vector2i] = [start]
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	for i in range(steps):
		var dir = directions[randi() % 4]
		current += dir
		if not path.has(current):
			path.append(current)
			
	return path
