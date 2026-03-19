# method_track_logic.gd
# Using Method Tracks for high-precision game logic triggers [13]
extends Node

# EXPERT NOTE: Always use CALL_MODE_DISCRETE for logic to avoid 
# accidental double-triggers on frame boundaries.

func setup_method_track(anim: Animation) -> void:
	var track_idx = anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(track_idx, ".")
	
	# Trigger a logic event at 0.5s
	anim.track_insert_key(track_idx, 0.5, {
		"method": "_on_hitbox_active",
		"args": [true]
	})
	
	# Deactivate at 0.8s
	anim.track_insert_key(track_idx, 0.8, {
		"method": "_on_hitbox_active",
		"args": [false]
	})
	
	# CRITICAL: Discrete mode ensures the method is called exactly once.
	anim.track_set_call_mode(track_idx, Animation.CALL_MODE_DISCRETE)

func _on_hitbox_active(active: bool) -> void:
	print("Hitbox state changed: ", active)
	# Logic for enabling/disabling Area3D/2D hitboxes
