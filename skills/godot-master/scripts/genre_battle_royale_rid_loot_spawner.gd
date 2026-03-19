# rid_loot_spawner.gd
# Bypassing Nodes for massive loot quantity
extends Node

# EXPERT NOTE: Rendering thousands of loot items as nodes 
# is slow. Use RenderingServer directly for CPU efficiency.

func spawn_loot_render_only(pos: Vector3, mesh_rid: RID):
	var instance = RenderingServer.instance_create()
	RenderingServer.instance_set_base(instance, mesh_rid)
	RenderingServer.instance_set_scenario(instance, get_world_3d().scenario)
	RenderingServer.instance_set_transform(instance, Transform3D(Basis(), pos))
	return instance
