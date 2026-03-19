# fast_wall_detector.gd
extends Node2D
class_name FastWallDetector

# Physics-Based Wall Detection (Raycasting)
# Uses nodeless raycasting via DirectSpaceState for optimal performance.

func is_touching_wall(offset: Vector2) -> bool:
    var space_state := get_world_2d().direct_space_state
    
    # Create ray query from current position toward the offset target length.
    var target = global_position + offset
    var query := PhysicsRayQueryParameters2D.create(global_position, target)
    
    # EXTREMELY IMPORTANT: Exclude the parent node (Player) to prevent self-collision.
    if get_parent() is CollisionObject2D:
        query.exclude = [get_parent().get_rid()]
    
    var result := space_state.intersect_ray(query)
    return not result.is_empty()
