# GPU Fill Rate Optimization via MeshInstance2D
extends Node2D

## Drawing large transparent areas is expensive for GPUs (Fill Rate bottleneck).
## Use MeshInstance2D to create a tight polygon around your sprite.

func convert_sprite_to_optimized_mesh(sprite: Sprite2D) -> MeshInstance2D:
	# While normally done in the Editor (Sprite2D > "Convert to MeshInstance2D"),
	# this conceptual script highlights the logic.
	
	var mesh_node = MeshInstance2D.new()
	mesh_node.texture = sprite.texture
	
	# Architecture Tip: For thousands of trees/grass, MeshInstance2D is mandatory
	# because it bypasses the transparent alpha blending overhead for empty space.
	
	# In your master scene, prefer MeshInstance2D over Sprite2D for static
	# environmental animations (like swaying trees) to protect your GPU budget.
	return mesh_node
