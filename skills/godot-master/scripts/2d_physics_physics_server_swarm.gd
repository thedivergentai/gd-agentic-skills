# PhysicsServer2D High-Performance Swarm
extends Node2D

## For thousands of objects, bypassing the SceneTree is mandatory.
## This script manages raw physics bodies via the PhysicsServer2D.

var bodies = []
var shape

func _ready() -> void:
    shape = PhysicsServer2D.circle_shape_create()
    PhysicsServer2D.shape_set_data(shape, 10.0) # Radius 10

    for i in range(1000):
        var body = PhysicsServer2D.body_create()
        PhysicsServer2D.body_set_space(body, get_world_2d().space)
        PhysicsServer2D.body_add_shape(body, shape)
        
        # Set initial position
        var transform = Transform2D(0, Vector2(randf() * 1000, randf() * 1000))
        PhysicsServer2D.body_set_state(body, PhysicsServer2D.BODY_STATE_TRANSFORM, transform)
        
        bodies.append(body)

func _exit_tree() -> void:
    # Manual memory management is required for Server objects
    for body in bodies:
        PhysicsServer2D.free_rid(body)
    PhysicsServer2D.free_rid(shape)
