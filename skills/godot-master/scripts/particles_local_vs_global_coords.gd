# local_vs_global_coords.gd
# Handling local vs global coordinate space for trails and localized effects
extends GPUParticles3D

func configure_trail_mode(is_trail: bool) -> void:
	# local_coords = false: Particles are left behind in global space (Smoke Trails) [36].
	# local_coords = true: Particles move WITH the emitter (Magic Aura).
	local_coords = !is_trail
	
func safe_teleport(new_pos: Vector3) -> void:
	emitting = false
	global_position = new_pos
	# CRITICAL: If local_coords=false, teleporting leaves a visual gap.
	# restart() clears the trail instantly for a clean teleport [38].
	restart() 
	emitting = true
