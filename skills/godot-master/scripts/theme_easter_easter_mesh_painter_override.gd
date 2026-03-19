class_name EasterMeshPainterOverride
extends Node

## Expert seasonal material swapper for 3D meshes.
## Replaces standard surface materials with Easter-themed versions.

@export var mesh_instance: MeshInstance3D
@export var easter_material: Material

func apply_easter_material() -> void:
	if not mesh_instance or not easter_material: return
	
	# Expert: Use surface override to avoid modifying the Mesh resource itself.
	mesh_instance.set_surface_override_material(0, easter_material)

func remove_easter_material() -> void:
	if mesh_instance:
		mesh_instance.set_surface_override_material(0, null)

## Rule: Always use 'surface_override' for seasonal changes to preserve original assets.
