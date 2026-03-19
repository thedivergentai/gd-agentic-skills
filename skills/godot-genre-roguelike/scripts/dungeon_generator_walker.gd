class_name DrunkardsWalk extends RefCounted

## Drunkard's Walk algorithm for carving procedural dungeons.
## Uses Vector2i for discrete grid coordinates and isolated RNG for determinism.

static func generate_map(start_pos: Vector2i, steps: int, rng: RandomNumberGenerator) -> Dictionary:
	var map_data: Dictionary = {}
	var current_pos := start_pos
	
	# 4-way orthogonal directions (standard top-down)
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	for i in range(steps):
		# Mark current position as floor (using StringName for performance)
		map_data[current_pos] = &"floor"
		
		# Pick a random direction from the RNG instance
		var dir := directions[rng.randi() % directions.size()]
		current_pos += dir
		
	return map_data
