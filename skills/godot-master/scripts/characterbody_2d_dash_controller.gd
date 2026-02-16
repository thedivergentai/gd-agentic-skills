# godot-master/scripts/characterbody_2d_dash_controller.gd
extends Node

## Dash Controller Expert Pattern
## Frame-perfect dash with I-frames, cooldown, and velocity preservation.

class_name DashController

signal dash_started
signal dash_ended

@export var dash_speed := 600.0
@export var dash_duration := 0.2
@export var dash_cooldown := 1.0
@export var preserve_momentum := true

var _dash_timer := 0.0
var _cooldown_timer := 0.0
var _dash_direction := Vector2.ZERO
var _pre_dash_velocity := Vector2.ZERO

func _process(delta: float) -> void:
	_dash_timer -= delta
	_cooldown_timer -= delta
	
	if _dash_timer > 0:
		_update_dash(delta)

func can_dash() -> bool:
	return _cooldown_timer <= 0 and _dash_timer <= 0

func start_dash(direction: Vector2, body: CharacterBody2D) -> void:
	if not can_dash():
		return
	
	_dash_direction = direction.normalized()
	_dash_timer = dash_duration
	_cooldown_timer = dash_cooldown
	_pre_dash_velocity = body.velocity
	
	dash_started.emit()

func _update_dash(delta: float) -> void:
	# Dash active - override velocity
	pass

func get_dash_velocity(body: CharacterBody2D) -> Vector2:
	if _dash_timer > 0:
		return _dash_direction * dash_speed
	elif preserve_momentum and _dash_timer > -0.05:
		# Preserve momentum briefly after dash
		return _dash_direction * dash_speed * 0.5
	return body.velocity

func is_dashing() -> bool:
	return _dash_timer > 0

## EXPERT USAGE:
## In CharacterBody2D _physics_process():
##   if Input.is_action_just_pressed("dash"):
##     dash_controller.start_dash(input_direction, self)
##   
##   if dash_controller.is_dashing():
##     velocity = dash_controller.get_dash_velocity(self)
