# skills/2d-physics/code/physics_queries.gd
extends Node2D

## High-Performance Physics Queries Pattern
## Demonstrates using PhysicsDirectSpaceState2D for queries outside the main tree.

func perform_expert_raycast(from: Vector2, to: Vector2, exclude: Array[RID] = []) -> Dictionary:
    # 1. Access the direct space state (Thread-safe only in _physics_process)
    var space_state := get_world_2d().direct_space_state
    
    # 2. Configure the query
    var query := PhysicsRayQueryParameters2D.create(from, to)
    query.exclude = exclude
    query.collision_mask = 0b0001 # Layer 1 (World)
    
    # Optional: Enable hit_from_inside if needed
    # query.hit_from_inside = true
    
    # 3. Execute
    var result := space_state.intersect_ray(query)
    
    if result:
        # print("Hit: ", result.collider)
        return result
    return {}

func perform_shapecast(origin: Vector2, shape: Shape2D, motion: Vector2) -> Array[Dictionary]:
    # ShapeCast2D is great as a node, but for manual queries:
    var space_state := get_world_2d().direct_space_state
    
    var query := PhysicsShapeQueryParameters2D.new()
    query.shape = shape
    query.transform = Transform2D(0, origin)
    query.motion = motion
    
    # intersect_shape is for overlap detection
    # cast_motion is for finding how far a shape can move before hitting something
    var results := space_state.intersect_shape(query)
    return results

## WHY USE THIS?
## Bypassing the Node2D tree for physics queries is significantly faster 
## when performing hundreds of checks (e.g., AI vision, projectile prediction).
