# direct_hitbox_query.gd
# Bypassing Area2D for frame-perfect intersection tests
extends Node2D

# EXPERT NOTE: For precision, query the PhysicsServer directly. 
# Area2D overlaps are only updated once per physics frame.

func check_hitbox(query_pos: Vector2, radius: float) -> Array:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	
	var shape = CircleShape2D.new()
	shape.radius = radius
	query.shape_rid = shape.get_rid()
	query.transform = Transform2D(0, query_pos)
	
	return space_state.intersect_shape(query)
