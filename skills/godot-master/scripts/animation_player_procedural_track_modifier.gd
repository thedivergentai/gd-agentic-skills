# procedural_track_modifier.gd
# Modifying specific animation tracks via code at runtime [5]
extends AnimationPlayer

func tweak_jump_height(new_height: float) -> void:
	var anim: Animation = get_animation("jump")
	
	# Find the track index for the Y position
	var track_idx = anim.find_track(".:position:y", Animation.TYPE_VALUE)
	
	if track_idx != -1:
		# Update the peak keyframe (usually in the middle)
		# Expert: Use track_set_key_value instead of deleting/re-adding
		var key_idx = 1 # Assume index 1 is the peak
		anim.track_set_key_value(track_idx, key_idx, -new_height)
		
		# If you need immediate visual feedback while paused:
		if not is_playing():
			seek(current_animation_position, true)
