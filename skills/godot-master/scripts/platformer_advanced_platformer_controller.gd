# godot-master/scripts/platformer_advanced_platformer_controller.gd
extends CharacterBody2D

## Advanced Platformer Controller
## Expert implementation of "game feel" mechanics: Coyote Time, Jump Buffering, Apex Modifiers.

class_name AdvancedPlatformerController

@export_group("Movement")
@export var move_speed: float = 200.0
@export var acceleration: float = 1800.0
@export var friction: float = 2000.0
@export var air_acceleration: float = 1200.0
@export var air_friction: float = 800.0

@export_group("Jump")
@export var jump_height: float = 80.0
@export var jump_time_to_peak: float = 0.35
@export var jump_time_to_descent: float = 0.3
@export var variable_jump_height: bool = true

@export_group("Assists")
@export var coyote_time: float = 0.1
@export var jump_buffer: float = 0.15
@export var apex_duration: float = 0.1
@export var apex_gravity_mult: float = 0.5

# Detailed Physics Calculation
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# State
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _is_jumping: bool = false

func _physics_process(delta: float) -> void:
    # 1. Input Handling
    var input_x = Input.get_axis("move_left", "move_right")
    
    # 2. Gravity Application
    var gravity_mult = 1.0
    
    # Apex modifier: reduce gravity at the very peak of jump for "hang time"
    if _is_jumping and abs(velocity.y) < 100.0:
        gravity_mult = apex_gravity_mult
        
    if velocity.y < 0:
        velocity.y += jump_gravity * gravity_mult * delta
    else:
        velocity.y += fall_gravity * gravity_mult * delta
        
    # 3. Timers
    if is_on_floor():
        _coyote_timer = coyote_time
        _is_jumping = false
    else:
        _coyote_timer -= delta
        
    if Input.is_action_just_pressed("jump"):
        _jump_buffer_timer = jump_buffer
    else:
        _jump_buffer_timer -= delta
        
    # 4. Jump Execution
    if _jump_buffer_timer > 0 and (_coyote_timer > 0 or is_on_floor()):
        velocity.y = jump_velocity
        _is_jumping = true
        _jump_buffer_timer = 0
        _coyote_timer = 0
        
    # Variable Jump Height (releasing button cuts jump short)
    if variable_jump_height and Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= 0.5
        
    # 5. Horizontal Movement
    var target_accel = acceleration if is_on_floor() else air_acceleration
    var target_friction = friction if is_on_floor() else air_friction
    
    if input_x != 0:
        velocity.x = move_toward(velocity.x, input_x * move_speed, target_accel * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, target_friction * delta)
        
    move_and_slide()

## EXPERT USAGE:
## Adjust 'Jump Height' and 'Time To Peak' in inspector to tune feel.
## Gravity is calculated automatically from these values.
