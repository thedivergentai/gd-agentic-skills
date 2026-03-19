# Material Batching and Override logic
extends Node

## Efficiently sharing materials across multiple meshes
## to ensure GPU draw call batching.

func apply_global_material(group_name: String, mat: Material) -> void:
	for node in get_tree().get_nodes_in_group(group_name):
		if node is MeshInstance3D:
			# Override ensures we don't modify the base .mesh file
			node.material_override = mat
			
	# Result: All meshes in group now draw in a single state-locked batch.
