# soft_body_3d_interaction.gd
# Expert configuration for SoftBody3D (Flags, Cloaks, Foliage)
extends SoftBody3D

# EXPERT NOTE: Soft bodies are CPU heavy. Use them sparingly 
# and use 'Simulation Precision' sparingly.

func attach_to_point(path: NodePath, bone: String = ""):
	# Attaching a flag to a flagpole or character bone
	var pin_point = 0 # Vertex index
	set_point_pinned(pin_point, true)
	# Logic usually involves Editor configuration, but scriptable for dynamic spawn
