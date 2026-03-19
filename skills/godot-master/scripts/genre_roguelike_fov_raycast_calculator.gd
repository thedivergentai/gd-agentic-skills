class_name FOVCalculator extends Node2D

## High-performance Field-of-View calculation using raycasts.
## Bypasses Area2D overhead by querying PhysicsDirectSpaceState2D directly.

func calculate_fov(player_pos: Vector2, radius: float, targets: Array[Vector2]) -> Array[Vector2]:
	var visible_targets: Array[Vector2] = []
	var space_state := get_world_2d().direct_space_state
	var radius_sq := radius * radius
	
	for target in targets:
		# Early exit for distance
		if player_pos.distance_squared_to(target) > radius_sq:
			continue
			
		# Construct raycast query
		var query := PhysicsRayQueryParameters2D.create(player_pos, target)
		
		# Exclude player to prevent self-collision
		if get_parent() is CollisionObject2D:
			query.exclude = [get_parent().get_rid()]
		
		# If empty, path is clear (visible)
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			visible_targets.append(target)
			
	return visible_targets
