# Directional Light Shadow Bias Tuner
extends DirectionalLight3D

## Prevents 'Peter Panning' (shadows detached from feet)
## and 'Shadow Acne' (striped artifacts on surfaces).

func optimize_shadow_physics() -> void:
	# Bias depends on cascade split distances. 
	# Too high = Peter Panning. Too low = Shadow Acne.
	shadow_bias = 0.05 
	
	# Normal bias pushes the shadow caster depth along normals.
	# Fixes acne on flat slopes.
	shadow_normal_bias = 2.0
	
	# Transmittance bias for SSS materials
	shadow_transmittance_bias = 0.05
	
	# Architecture Tip: Use Contact Test to close small gaps at contact points.
	shadow_blur = 1.0
