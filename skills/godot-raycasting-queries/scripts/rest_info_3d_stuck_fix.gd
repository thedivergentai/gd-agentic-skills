# rest_info_3d_stuck_fix.gd
# Using get_rest_info for instant overlap/stuck detection
extends CollisionObject3D

# EXPERT NOTE: Area3D has a frame delay. get_rest_info is instant.

func detect_stuck_state():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	
	# Query using the object's own first shape
	query.shape_rid = get_shape_rid(0)
	query.transform = global_transform
	
	# get_rest_info returns exact contact position and normal if overlapping
	var res = space_state.get_rest_info(query)
	if res.size() > 0:
		# Object is stuck. 'normal' points away from collision.
		return res.normal
	return null
