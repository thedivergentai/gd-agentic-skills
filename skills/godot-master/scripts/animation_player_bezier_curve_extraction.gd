# bezier_curve_extraction.gd
# Extracting Bezier track data for custom physics/logic [115]
extends Node

func get_bezier_at_runtime(anim: Animation, track_path: String, time: float) -> float:
	var track_idx = anim.find_track(track_path, Animation.TYPE_BEZIER)
	if track_idx == -1: return 0.0
	
	# Expert: bezier_track_interpolate returns the exact value at 'time'
	# accounting for handle lengths and angles.
	return anim.bezier_track_interpolate(track_idx, time)

# Example: Use Bezier to drive a custom particle emission rate
func _process(delta: float) -> void:
	if $AnimationPlayer.is_playing():
		var anim = $AnimationPlayer.get_animation($AnimationPlayer.current_animation)
		var t = $AnimationPlayer.current_animation_position
		var rate = get_bezier_at_runtime(anim, ".:emission_rate", t)
		$GPUParticles3D.amount_ratio = clamp(rate, 0.0, 1.0)
