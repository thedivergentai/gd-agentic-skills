# multimesh_vegetation.gd
# Drawing thousands of environment assets in one draw call
extends MultiMeshInstance3D

# EXPERT NOTE: Battle Royale terrain requires dense foliage. 
# MultiMeshInstance3D is essential for 100k+ instances.

func populate_grass(count: int, area: Rect2):
	multimesh.instance_count = count
	for i in range(count):
		var pos = Transform3D(Basis(), Vector3(randf_range(area.position.x, area.end.x), 0, randf_range(area.position.y, area.end.y)))
		multimesh.set_instance_transform(i, pos)
