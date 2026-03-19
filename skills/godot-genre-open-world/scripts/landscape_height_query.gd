# landscape_height_query.gd
extends Node3D
class_name LandscapeHeightQuery

# Grid-Based Raycast Floor Query
# Uses PhysicsDirectSpaceState for high-performance height checks for object placement.

func get_height_at(pos_x: float, pos_z: float) -> float:
    var space_state := get_world_3d().direct_space_state
    
    # Query from skyward downwards.
    var ray_start := Vector3(pos_x, 5000.0, pos_z)
    var ray_end := Vector3(pos_x, -1000.0, pos_z)
    
    var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
    var result := space_state.intersect_ray(query)
    
    if not result.is_empty():
        return result.position.y
    return 0.0
