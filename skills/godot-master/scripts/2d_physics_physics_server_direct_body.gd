# physics_server_direct_body.gd
# High-performance physics using PhysicsServer2D directly [17]
extends Node2D

# EXPERT NOTE: For 1000s of objects (bullets, debris), PhysicsServer2D 
# is significantly faster than using RigidBody2D nodes as it 
# bypasses the scene tree overhead.

var bodies: Array[RID] = []
var shape: RID

func _ready() -> void:
	shape = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape, 10.0) # Radius 10
	
	for i in range(100):
		var body = PhysicsServer2D.body_create()
		PhysicsServer2D.body_set_mode(body, PhysicsServer2D.BODY_MODE_RIGID)
		PhysicsServer2D.body_add_shape(body, shape)
		PhysicsServer2D.body_set_space(body, get_world_2d().space)
		PhysicsServer2D.body_set_state(body, PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(0, Vector2(randf()*500, randf()*500)))
		bodies.append(body)

func _exit_tree() -> void:
	# ALWAYS clean up RIDs manually to prevent memory leaks
	for body in bodies:
		PhysicsServer2D.free_rid(body)
	PhysicsServer2D.free_rid(shape)
