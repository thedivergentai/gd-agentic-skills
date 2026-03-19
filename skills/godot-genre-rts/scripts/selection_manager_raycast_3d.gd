# rts_selection_manager.gd
extends Node3D
class_name RTSSelectionManager

# Fast Physics-Server Raycasting for Unit Selection
# Bypasses SceneTree overhead by querying the C++ PhysicsServer3D directly.

func select_unit_at_mouse(camera: Camera3D, mouse_pos: Vector2) -> Object:
    var space_state := get_world_3d().direct_space_state
    
    # Standard ray projection from camera.
    var origin := camera.project_ray_origin(mouse_pos)
    var normal := camera.project_ray_normal(mouse_pos)
    
    var query := PhysicsRayQueryParameters3D.create(origin, origin + normal * 1000.0)
    query.collide_with_areas = false
    query.collide_with_bodies = true
    
    # Pattern: Direct server lookup is faster than Area3D detection for mass units.
    var result := space_state.intersect_ray(query)
    return result.get("collider") if not result.is_empty() else null
