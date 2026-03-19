# precise_audio_sync.gd
# Using TYPE_AUDIO tracks for perfect timing with pitch/volume control [93]
extends AnimationPlayer

func add_dynamic_sfx(anim: Animation, stream: AudioStream, time: float) -> void:
	var track_idx = anim.add_track(Animation.TYPE_AUDIO)
	track_set_path(track_idx, "AudioStreamPlayer")
	
	# Expert: Audio tracks handle polyphony and volume ramping internally
	anim.audio_track_insert_key(track_idx, time, stream)
	
	# Control volume (-60 to 24 dB)
	anim.audio_track_set_key_volume(track_idx, 0, -3.0) 
	
	# Use START_OFFSET to skip introductory silence in long files
	anim.audio_track_set_key_start_offset(track_idx, 0, 0.1)
