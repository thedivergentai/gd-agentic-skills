# godot-master/scripts/animation_player_audio_sync_tracks.gd
extends AnimationPlayer

## Sub-Frame Audio Sync Expert Pattern
## Technical blueprints for integrating AudioStreamPlayer tracks.

func setup_footstep_audio(sfx_node: AudioStreamPlayer2D) -> void:
    var anim: Animation = get_animation("walk")
    if not anim: return
    
    # 1. Add an Audio Track
    var track_index := anim.add_track(Animation.TYPE_AUDIO)
    anim.track_set_path(track_index, str(get_path_to(sfx_node)))
    
    # 2. Insert the Sound Trigger at the foot-fall frame (e.g. 0.3s)
    # The 'stream' is used from the AudioStreamPlayer2D node.
    anim.audio_track_insert_key(track_index, 0.3, sfx_node.stream)
    
    # 3. Enable 'Use Blend' to handle cross-fades between animations
    anim.audio_track_set_use_blend(track_index, true)

## EXPERT NOTE:
## Using Audio Tracks is superior to 'get_node().play()' via Method Tracks 
## because Audio Tracks automatically handle stopping/fading when 
## animations are interrupted or blended.
