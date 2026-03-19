# dash_state_controller.gd
# Frame-data driven dash logic with invincibility frames
extends CharacterBody2D

@export var dash_speed := 800.0
@export var dash_duration := 0.2

var _is_dashing := false
var _dash_timer := 0.0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dash") and not _is_dashing:
		_start_dash()
		
	if _is_dashing:
		_dash_timer -= delta
		if _dash_timer <= 0:
			_is_dashing = false
	else:
		# Normal gravity
		velocity += get_gravity() * delta

	move_and_slide()

func _start_dash():
	_is_dashing = true
	_dash_timer = dash_duration
	velocity.x = Input.get_axis("left", "right") * dash_speed
	velocity.y = 0 # No vertical movement during dash
