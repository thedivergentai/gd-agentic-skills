# texture_array_batching.gd
# Reducing state changes with TextureArrays
extends Node

# EXPERT NOTE: Switching textures is a slow "state change" 
# for GPUs. Using Texture2DArray or Atlases allows 
# the RenderingServer to batch multiple draw calls into one.

@export var tex_array: Texture2DArray

func apply_material_index(sprite: Sprite2D, index: int):
	sprite.material.set_shader_parameter("layer_index", index)
	# Shader then pulls from tex_array[index]
	pass
