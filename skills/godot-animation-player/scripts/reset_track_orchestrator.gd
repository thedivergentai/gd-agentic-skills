# reset_track_orchestrator.gd
# Robust RESET track management for multi-layered animations [12]
extends Node

@onready var anim_player: AnimationPlayer = $AnimationPlayer

# EXPERT NOTE: If you have many entities, manually calling RESET 
# can be faster than letting Godot's auto-reset trigger layout updates.

func force_hard_reset() -> void:
	if anim_player.has_animation("RESET"):
		# Seek(0, true) forces immediate property application 
		# even if the player is paused.
		anim_player.play("RESET")
		anim_player.advance(0) # Immediate update
		anim_player.stop()

func play_safe(anim_name: String) -> void:
	# Always ensure we start from a clean slate if the previous 
	# animation modified persistent state.
	force_hard_reset()
	anim_player.play(anim_name)
