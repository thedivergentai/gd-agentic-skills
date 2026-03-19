# hitscan_weapon_query.gd
extends Node3D
class_name HitscanWeaponQuery

# High-Performance Hitscan Query (Nodeless)
# Fires a raycast instantly using the C++ physics server.

@export var damage := 25.0
@export var range := 1000.0

func fire_hitscan(camera: Camera3D, player_rid: RID) -> Dictionary:
    var space_state := get_world_3d().direct_space_state
    var viewport := get_viewport()
    var center_screen := viewport.get_visible_rect().size / 2.0
    
    var origin := camera.project_ray_origin(center_screen)
    var end := origin + camera.project_ray_normal(center_screen) * range
    
    var query := PhysicsRayQueryParameters3D.create(origin, end)
    # NEVER shoot yourself: Exclude player RID.
    query.exclude = [player_rid]
    query.collide_with_areas = false
    
    var result := space_state.intersect_ray(query)
    if not result.is_empty():
        var collider = result.get("collider")
        # Duck-typing damage application for decoupled logic.
        if collider.has_method(&"take_damage"):
            collider.take_damage(damage)
            
    return result
