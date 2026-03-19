# query_exclusion_optimization.gd
# Optimizing queries by specifically excluding RIDs
extends Node

var _ignored_rids: Array[RID] = []

func add_ignored_body(body: CollisionObject3D):
	_ignored_rids.append(body.get_rid())

func efficient_query(from: Vector3, to: Vector3):
	var query = PhysicsRayQueryParameters3D.create(from, to)
	# EXPERT: Passing RIDs directly is faster than NodePath arrays
	query.exclude = _ignored_rids
	
	return get_world_3d().direct_space_state.intersect_ray(query)
