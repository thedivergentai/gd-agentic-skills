# impulse_response_handler.gd
# Handling external forces (Knockback, Wind) with move_and_slide
extends CharacterBody2D

var _external_force := Vector2.ZERO

func apply_knockback(dir: Vector2, force: float):
	_external_force = dir.normalized() * force

func _physics_process(delta: float) -> void:
	velocity += _external_force
	# Decay external force over time (friction)
	_external_force = _external_force.lerp(Vector2.ZERO, 0.2)
	
	move_and_slide()
