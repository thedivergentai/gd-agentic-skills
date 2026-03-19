# character_part_swapper_tracks.gd
# Swapping meshes/textures via AnimationPlayer tracks for customization
extends Node3D

# This pattern uses Value tracks with NodePath properties 
# to enable/disable specific character accessories during animations.

func setup_sheathe_track(anim: Animation) -> void:
	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	
	# At the start of 'sheathe', sword in hand is visible
	anim.track_set_path(track_idx, "Skeleton3D/HandSlot/Sword:visible")
	anim.track_insert_key(track_idx, 0.0, true)
	anim.track_insert_key(track_idx, 0.5, false) # Hidden when put away
	
	var sheath_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(sheath_track, "Skeleton3D/BackSlot/SwordSheath:visible")
	anim.track_insert_key(sheath_track, 0.0, false)
	anim.track_insert_key(sheath_track, 0.5, true) # Shown on back
