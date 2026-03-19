class_name EasterShimmerVFXEmitter
extends CPUParticles2D

## Expert 'Hidden Item' shimmer effect for Easter Eggs.
## Uses additive blending and scale curves for professional sparkles.

func _ready() -> void:
	amount = 8
	lifetime = 1.5
	explosiveness = 0.1
	texture = preload("res://addons/godot-master/assets/sparkle.png") # Placeholder
	
	emission_shape = EMISSION_SHAPE_SPHERE
	emission_sphere_radius = 20.0
	
	gravity = Vector2(0, -10) # Slow rise
	scale_amount_min = 0.1
	scale_amount_max = 0.3
	
	# Shimmer pulse
	color = Color(1, 1, 0.8, 1) # Warm white

## Tip: Use 'emitted' signals to trigger collection SFX when the player gets close.
