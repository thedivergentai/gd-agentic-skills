# aoe_physics_query.gd
extends Node3D
class_name AOEPhysicsQuery

# High-Performance AoE Server Query
# Directly queries the C++ physics server for massive AoE spells, bypassing Node overhead.

func execute_explosion(radius: float, damage: float) -> void:
    var space_state := get_world_3d().direct_space_state
    
    # Configure the spatial query parameters.
    var query := PhysicsShapeQueryParameters3D.new()
    var sphere := SphereShape3D.new()
    sphere.radius = radius
    query.shape = sphere
    query.transform = global_transform
    
    # Intersects all physics bodies in the radius instantly [28].
    var results: Array[Dictionary] = space_state.intersect_shape(query)
    
    for hit in results:
        var target = hit["collider"]
        if target.has_method(&"take_damage"):
            target.take_damage(damage)
