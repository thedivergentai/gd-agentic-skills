# multiple_hit_piercing_ray.gd
# Implementing projectiles that pierce through multiple enemies
extends Node3D

func raycast_pierce(from: Vector3, to: Vector3, max_hits: int = 5):
	var hits = []
	var space_state = get_world_3d().direct_space_state
	var exclude = [self.get_rid()]
	
	for i in range(max_hits):
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = exclude
		var result = space_state.intersect_ray(query)
		
		if result:
			hits.append(result)
			# Exclude the RID of the hit object to pierce it in the next iteration
			exclude.append(result.rid) 
		else:
			break
			
	return hits
