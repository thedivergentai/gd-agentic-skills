# variable_jump_height.gd
# Implementing 'Short Hop' vs 'Full Jump' logic
extends CharacterBody2D

@export var jump_velocity := -400.0
@export var min_jump_velocity := -200.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		# If player releases jump mid-air, cut vertical velocity
		if Input.is_action_just_released("jump") and velocity.y < min_jump_velocity:
			velocity.y = min_jump_velocity

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
