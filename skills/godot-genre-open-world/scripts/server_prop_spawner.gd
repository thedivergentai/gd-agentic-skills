# server_prop_spawner.gd
extends Node
class_name ServerPropSpawner

# Nodeless Server-Side Object Placement
# Spawns visuals directly in RenderingServer to bypass SceneTree overhead.

var _spawned_rids: Array[RID] = []

func spawn_visual_prop(mesh_rid: RID, material_rid: RID, xform: Transform3D) -> RID:
    # Pattern: Create rendering instance directly.
    var instance_rid := RenderingServer.instance_create()
    RenderingServer.instance_set_base(instance_rid, mesh_rid)
    RenderingServer.instance_set_surface_override_material(instance_rid, 0, material_rid)
    RenderingServer.instance_set_transform(instance_rid, xform)
    
    # Assign to current 3D world scenario.
    var scenario := get_world_3d().scenario
    RenderingServer.instance_set_scenario(instance_rid, scenario)
    
    _spawned_rids.append(instance_rid)
    return instance_rid

func clear_all() -> void:
    for rid in _spawned_rids:
        RenderingServer.free_rid(rid)
    _spawned_rids.clear()
