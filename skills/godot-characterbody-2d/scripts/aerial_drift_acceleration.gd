# aerial_drift_acceleration.gd
# Precise air control logic for feel-focused platformers
extends CharacterBody2D

@export var air_acceleration := 500.0
@export var max_air_speed := 300.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		var dir = Input.get_axis("left", "right")
		# Only accelerate if we aren't at max air speed
		if abs(velocity.x) < max_air_speed or sign(dir) != sign(velocity.x):
			velocity.x += dir * air_acceleration * delta
	
	move_and_slide()
