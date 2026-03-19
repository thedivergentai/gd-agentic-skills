# physics_direct_space_query.gd
# Low-level space state queries for complex AI vision [Raycasting]
extends Node2D

# EXPERT NOTE: Querying the space state directly is the fastest way 
# to perform raycasts in bulk without creating nodes.

func check_line_of_sight(from: Vector2, to: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	# Configure the query
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = 1 # World layer
	query.exclude = [get_parent().get_rid()] # Exclude self
	
	var result = space_state.intersect_ray(query)
	
	# result is empty if nothing was hit
	return result.is_empty()
