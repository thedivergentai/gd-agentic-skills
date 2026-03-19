# server_projectile_instance.gd
extends Node
class_name ServerProjectileInstance

# Nodeless Projectile Spawning via Servers
# Direct RenderingServer calls for high-volume minigun bullets.

var _bullet_rid: RID

func spawn_visual_bullet(mesh_rid: RID, xform: Transform3D) -> void:
    # Pattern: Create instance directly in visual server to bypass SceneTree overhead.
    _bullet_rid = RenderingServer.instance_create()
    RenderingServer.instance_set_base(_bullet_rid, mesh_rid)
    RenderingServer.instance_set_scenario(_bullet_rid, get_world_3d().scenario)
    RenderingServer.instance_set_transform(_bullet_rid, xform)

func update_visual(xform: Transform3D) -> void:
    if _bullet_rid.is_valid():
        RenderingServer.instance_set_transform(_bullet_rid, xform)

func _exit_tree() -> void:
    if _bullet_rid.is_valid():
        RenderingServer.free_rid(_bullet_rid)
