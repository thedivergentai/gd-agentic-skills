# ray_query_3d_vision.gd
# Expert 3D line-of-sight using direct space state [Raycasting]
extends Node3D

func can_see_target(target: Node3D) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, target.global_position)
	query.collision_mask = 1 # World
	query.exclude = [get_parent().get_rid() if get_parent() is CollisionObject3D else RID()]
	
	var result = space_state.intersect_ray(query)
	return result.is_empty() or result.collider == target
