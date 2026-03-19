# analog_deadzone_manager.gd
# Expert radial deadzone management for analog sticks [24]
extends Node

# PROBLEM: Axial deadzones (X/Y separately) cause "cross-shaped" deadzones.
# SOLUTION: Radial deadzone (vector length) provides a circular, natural feel.

@export var deadzone: float = 0.2

func get_movement_vector() -> Vector2:
	var raw = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if raw.length() < deadzone:
		return Vector2.ZERO
	
	# Optional: Scaled Radial Deadzone (remaps 0.2..1.0 to 0.0..1.0)
	return raw.normalized() * ((raw.length() - deadzone) / (1.0 - deadzone))
