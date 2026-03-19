# skills/characterbody-2d/scripts/wall_jump_controller.gd
extends Node

## Wall Jump Controller Expert Pattern
## Slide detection, wall cling, and wall jump with velocity preservation.

class_name WallJumpController

signal wall_jump_executed

@export var wall_slide_speed := 60.0
@export var wall_jump_velocity := Vector2(400, -500)
@export var wall_cling_duration := 0.3

var _is_on_wall_left := false
var _is_on_wall_right := false
var _wall_cling_timer := 0.0

func update(body: CharacterBody2D, delta: float) -> void:
	# Detect which wall we're touching
	_is_on_wall_left = body.is_on_wall() and body.get_wall_normal().x > 0
	_is_on_wall_right = body.is_on_wall() and body.get_wall_normal().x < 0
	
	# Update cling timer
	if is_on_any_wall():
		_wall_cling_timer = wall_cling_duration
	else:
		_wall_cling_timer -= delta

func is_on_any_wall() -> bool:
	return _is_on_wall_left or _is_on_wall_right

func apply_wall_slide(body: CharacterBody2D) -> void:
	if is_on_any_wall() and body.velocity.y > 0:
		body.velocity.y = min(body.velocity.y, wall_slide_speed)

func can_wall_jump() -> bool:
	return _wall_cling_timer > 0

func execute_wall_jump(body: CharacterBody2D, input_direction: float) -> bool:
	if not can_wall_jump():
		return false
	
	# Jump away from wall
	var jump_dir := 1.0 if _is_on_wall_left else -1.0
	
	# Override input if pushing into wall (auto-correct)
	if input_direction * jump_dir < 0:
		jump_dir *= -1
	
	body.velocity.x = wall_jump_velocity.x * jump_dir
	body.velocity.y = wall_jump_velocity.y
	
	_wall_cling_timer = 0
	wall_jump_executed.emit()
	return true

## EXPERT USAGE:
## var wall_jump := WallJumpController.new()
## 
## func _physics_process(delta):
##   wall_jump.update(self, delta)
##   wall_jump.apply_wall_slide(self)
##   
##   if Input.is_action_just_pressed("jump"):
##     if not wall_jump.execute_wall_jump(self, input_direction):
##       # Regular jump
