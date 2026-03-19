# action_state_machine.gd
# Tracking 'Just Pressed' vs 'Released' for complex behavior
extends Node

# PROBLEM: Input.is_action_just_pressed() only works once per frame. 
# State machines need to know if an action is currently in its 'Release' phase.

var is_jumping: bool = false
var is_falling: bool = false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		is_jumping = true
		_start_jump()
		
	if Input.is_action_just_released("jump") and is_jumping:
		is_jumping = false
		is_falling = true
		_end_jump_early() # Variable jump height logic
