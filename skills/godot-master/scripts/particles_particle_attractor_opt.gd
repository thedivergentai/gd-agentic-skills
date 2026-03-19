# particle_attractor_opt.gd
# Isolating particle interactions using cull_mask/layers
extends GPUParticles3D

func setup_isolated_attractor(attractor: GPUParticlesAttractorSphere3D) -> void:
	# Optimization: ONLY interact with particles on specific layers [24, 25]
	# Layer 2 = (1 << 1). Prevents thousands of global particles from checking this attractor.
	var specific_layer = (1 << 1)
	
	attractor.cull_mask = specific_layer
	
	# Ensure the particle system itself is on the matching layer
	# GeometryInstance3D.layers is used for particle interaction masking [26]
	self.layers = specific_layer
	
	# Enable interaction in the material
	if process_material is ParticleProcessMaterial:
		process_material.attractor_interaction_enabled = true
