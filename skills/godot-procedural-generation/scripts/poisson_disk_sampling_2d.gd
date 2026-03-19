# poisson_disk_sampling_2d.gd
# Blue-noise distribution for non-overlapping object placement
extends Node

# EXPERT NOTE: Poisson Disk Sampling is superior to random placement 
# for trees, rocks, and spawns because it guarantees a minimum 
# distance between objects, preventing 'clumping'.

func generate_points(width: float, height: float, radius: float, k: int = 30) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var spawn_points: Array[Vector2] = []
	
	spawn_points.append(Vector2(width/2, height/2))
	
	while spawn_points.size() > 0:
		var spawn_index = randi() % spawn_points.size()
		var spawn_centre = spawn_points[spawn_index]
		var accepted = false
		
		for i in range(k):
			var angle = randf() * PI * 2
			var dir = Vector2(cos(angle), sin(angle))
			var candidate = spawn_centre + dir * randf_range(radius, 2*radius)
			
			if _is_valid(candidate, width, height, radius, points):
				points.append(candidate)
				spawn_points.append(candidate)
				accepted = true
				break
		
		if not accepted:
			spawn_points.remove_at(spawn_index)
			
	return points

func _is_valid(p, w, h, r, points):
	if p.x < 0 or p.x > w or p.y < 0 or p.y > h: return false
	for other in points:
		if p.distance_to(other) < r: return false
	return true
