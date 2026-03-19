# Shader Variant State Manager
extends MeshInstance3D

## Architectural pattern for swapping material states
## (e.g., Frozen, Burnt, Dissolved) without resource duplication.

func set_dissolve_strength(v: float) -> void:
	var mat = get_active_material(0)
	if mat is ShaderMaterial:
		mat.set_shader_parameter("dissolve_amount", v)

func set_frozen_state(enabled: bool) -> void:
	var mat = get_active_material(0)
	if mat is ShaderMaterial:
		# Using a float uniform as a boolean for efficiency
		mat.set_shader_parameter("is_frozen", 1.0 if enabled else 0.0)
