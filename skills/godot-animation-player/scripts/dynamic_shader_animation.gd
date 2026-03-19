# dynamic_shader_animation.gd
# Animating Shader Uniforms via AnimationPlayer for VFX sync
extends MeshInstance3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func setup_dissolve_track(anim: Animation) -> void:
	# Note: Shader uniforms are accessed via the material property path
	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	
	# Path format: "MeshInstance3D:material_override:shader_parameter/dissolve_amount"
	# Or use index 0 for the first material
	anim.track_set_path(track_idx, ".:material_override:shader_parameter/dissolve_amount")
	
	anim.track_insert_key(track_idx, 0.0, 0.0)
	anim.track_insert_key(track_idx, 1.0, 1.0)
	
	# Use Cubic interpolation for smoother visual transitions
	anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_CUBIC)
