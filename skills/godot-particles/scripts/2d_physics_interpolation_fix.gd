# 2d_physics_interpolation_fix.gd
# Solving stuttering particles in 2D physics-based movement [56]
extends Node2D

func optimize_2d_trail_interpolation(particle_node: Node) -> void:
	# EXPERT NOTE: GPUParticles2D are NOT natively interpolated in Godot 4.3 [56].
	# If attached to a physics-moving body, they will stutter.
	# FIX: Use CPUParticles2D and enable fract_delta.
	
	if particle_node is CPUParticles2D:
		particle_node.fract_delta = true # Smoother fractional time integration [57]
		particle_node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	else:
		push_warning("GPUParticles2D stutter on physics bodies. Consider CPUParticles2D.")
