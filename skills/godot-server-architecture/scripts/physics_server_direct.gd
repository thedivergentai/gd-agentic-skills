# physics_server_direct.gd
# Bypassing SceneTree overhead for high-density simulations
extends Node3D

# EXPERT NOTE: For MMO-scale logic, Nodes are too expensive. 
# Create bodies directly on the PhysicsServer3D and manage RIDs.

var server_bodies: Array[RID] = []

func spawn_server_body(xform: Transform3D) -> RID:
	var body_rid := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body_rid, PhysicsServer3D.BODY_MODE_KINEMATIC)
	# Link to the 3D world's physics space
	PhysicsServer3D.body_set_space(body_rid, get_world_3d().space)
	PhysicsServer3D.body_set_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM, xform)
	
	server_bodies.append(body_rid)
	return body_rid

func _exit_tree():
	for rid in server_bodies:
		PhysicsServer3D.free_rid(rid)
