# round_timer_logic.gd
# Deterministic round management without Node timers
extends Node

# EXPERT NOTE: In fighting games, the timer must stay in sync 
# with the frames, not the wall-clock time.

var frames_remaining: int = 60 * 60 # 60 seconds at 60fps

func _physics_process(_delta):
	if frames_remaining > 0:
		frames_remaining -= 1
		if frames_remaining == 0:
			_on_time_out()

func _on_time_out():
	print("Round Ended by Frame Count")
