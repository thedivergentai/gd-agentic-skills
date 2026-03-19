class_name RevivalCheckpointVisuals
extends Node3D

## Expert Checkpoint Visual Feedback.
## Displays 'Active' vs 'Inactive' states using Emissive materials.

@export var active_material: StandardMaterial3D
@export var inactive_material: StandardMaterial3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

func set_active(is_active: bool) -> void:
	mesh.material_override = active_material if is_active else inactive_material

## Tip: Use a 'WorldEnvironment' glow to make active checkpoints highly visible.
