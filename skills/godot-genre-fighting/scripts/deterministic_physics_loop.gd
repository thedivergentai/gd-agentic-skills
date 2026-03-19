# deterministic_physics_loop.gd
# Locking gameplay logic to fixed timesteps
extends CharacterBody2D

# EXPERT NOTE: NEVER use _process() for fighting logic. 
# Determinism requires fixed _physics_process() execution.

func _physics_process(delta):
	_apply_fighter_logic(delta)
	move_and_slide()

func _apply_fighter_logic(_d):
	# Input polling and state transitions happen here
	pass
