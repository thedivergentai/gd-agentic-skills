# massive_swarm_multimesh.gd
# Managing millions of particles via MultiMeshInstance3D with interpolation [32]
extends MultiMeshInstance3D

func _ready() -> void:
	# Set high-speed interpolation for massive counts
	multimesh.physics_interpolation_quality = MultiMesh.MULTIMESH_INTERP_QUALITY_FAST

func submit_interpolated_swarm(current_data: PackedFloat32Array, previous_data: PackedFloat32Array) -> void:
	# Essential for smooth movement at high particle counts:
	# Submission of both buffers allows the engine to jitter-free interpolate 
	# between physics ticks even if the frame rate is higher than physics.
	multimesh.set_buffer_interpolated(current_data, previous_data)
