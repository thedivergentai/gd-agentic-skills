# rendering_ghost_spawner.gd
extends Node
class_name RenderingGhostSpawner

# Server-Side Rendering for Building Ghosts
# Bypasses SceneTree overhead for ghost visuals using RenderingServer.

var _ghost_rid: RID

func create_placement_ghost(mesh_rid: RID, scenario: RID) -> void:
    # Pattern: Directly instantiate in visual server to avoid costly Node lifecycle.
    _ghost_rid = RenderingServer.instance_create()
    RenderingServer.instance_set_base(_ghost_rid, mesh_rid)
    RenderingServer.instance_set_scenario(_ghost_rid, scenario)
    
    # Optional: Apply ghost shader/material.
    # RenderingServer.instance_set_surface_override_material(...)

func update_ghost_transform(xform: Transform3D) -> void:
    if _ghost_rid.is_valid():
        RenderingServer.instance_set_transform(_ghost_rid, xform)

func destroy_ghost() -> void:
    if _ghost_rid.is_valid():
        RenderingServer.free_rid(_ghost_rid)
