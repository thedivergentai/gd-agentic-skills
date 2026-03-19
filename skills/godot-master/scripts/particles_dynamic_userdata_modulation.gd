# dynamic_userdata_modulation.gd
# Passing runtime variables to particle shaders without breaking batching
extends GPUParticles3D

func set_vfx_intensity(intensity: float) -> void:
	# USERDATA variables (1-4) are designed for per-instance scripting [35].
	# This avoids duplicating the entire ShaderMaterial for every emitter.
	if process_material is ShaderMaterial:
		# Pack data into Vector4. x = intensity, y = spare, etc.
		process_material.set_shader_parameter("USERDATA1", Vector4(intensity, 0, 0, 0))
