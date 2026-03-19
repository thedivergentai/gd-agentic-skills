# frame_perfect_coyote_time.gd
# Implementing professional Coyote Time and Jump Buffering
extends CharacterBody2D

@export var speed := 300.0
@export var jump_velocity := -400.0
@export var coyote_frames := 6 # Frames allowed after falling
@export var buffer_frames := 10 # Frames jump input is remembered

var _coyote_timer := 0
var _jump_buffer := 0

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		_coyote_timer -= 1
	else:
		_coyote_timer = coyote_frames

	# Jump Buffer logic
	if Input.is_action_just_pressed("jump"):
		_jump_buffer = buffer_frames
	else:
		_jump_buffer -= 1

	# Execute Jump
	if _jump_buffer > 0 and _coyote_timer > 0:
		velocity.y = jump_velocity
		_coyote_timer = 0
		_jump_buffer = 0

	move_and_slide()
