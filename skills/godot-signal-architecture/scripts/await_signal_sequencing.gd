# await_signal_sequencing.gd
# Replacing timers and flag-based logic with awaits
extends Node

func start_boss_intro():
	print("Boss Roar!")
	# Create and await an inline timer
	await get_tree().create_timer(2.0).timeout
	
	$Boss/AnimationPlayer.play("camera_pan")
	# Wait for animation to finish signal
	await $Boss/AnimationPlayer.animation_finished
	
	print("Battle Start!")
	$UI/BossBar.show()
