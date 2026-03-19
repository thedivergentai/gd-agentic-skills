# multimesh_optimizer.gd
# Rendering thousands of instances with MultiMeshInstance
extends MultiMeshInstance3D

# EXPERT NOTE: MultiMesh uses hardware instancing. It is 
# significantly faster than spawning thousands of 
# individual nodes for grass, debris, or particles.

func setup(count: int):
	multimesh.instance_count = count
	for i in range(count):
		var trans = Transform3D(Basis(), Vector3(randf(), 0, randf()) * 10)
		multimesh.set_instance_transform(i, trans)
		multimesh.set_instance_color(i, Color(randf(), randf(), randf()))
