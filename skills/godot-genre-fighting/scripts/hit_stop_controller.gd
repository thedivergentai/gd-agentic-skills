# hit_stop_controller.gd
# Simulating fighter "impact freeze" via time scale
extends Node

# EXPERT NOTE: Hit-stop adds "juice" and impact feel. 
# Temporarily slowing Engine.time_scale provides immediate feedback.

func apply_hit_stop(duration: float = 0.1):
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout # Process during pause
	Engine.time_scale = 1.0
