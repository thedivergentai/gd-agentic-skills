# raycast_reflection_logic.gd
# Calculating laser/bullet bounces using collision normals
extends Node3D

func calculate_bounce_path(start: Vector3, dir: Vector3, max_bounces: int = 4):
	var space_state = get_world_3d().direct_space_state
	var path = [start]
	var current_pos = start
	var current_dir = dir.normalized()
	
	for i in max_bounces:
		var query = PhysicsRayQueryParameters3D.create(current_pos, current_pos + current_dir * 500)
		query.exclude = [self.get_rid()]
		var result = space_state.intersect_ray(query)
		
		if result:
			current_pos = result.position
			path.append(current_pos)
			# Reflect the direction based on the hit normal
			current_dir = current_dir.bounce(result.normal)
			# Offset from surface to prevent hit_from_inside on next step
			current_pos += current_dir * 0.05 
		else:
			path.append(current_pos + current_dir * 500)
			break
	return path
