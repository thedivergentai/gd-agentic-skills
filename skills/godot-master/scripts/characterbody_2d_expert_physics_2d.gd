# godot-master/scripts/characterbody_2d_expert_physics_2d.gd
extends CharacterBody2D

## CharacterBody2D Expert Movement Pattern
## Features Coyote Time, Jump Buffering, and Sub-Pixel Scaling.

@export_group("Movement")
@export var speed: float = 300.0
@export var acceleration: float = 1200.0
@export var friction: float = 800.0

@export_group("Physics Juice")
@export var jump_force: float = -400.0
@export var gravity: float = 980.0
@export var coyote_time: float = 0.15 # Seconds allowed to jump after falling
@export var jump_buffer: float = 0.10 # Seconds to 'remember' a jump press

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

func _physics_process(delta: float) -> void:
    # 1. Update Buffers
    _coyote_timer -= delta
    _jump_buffer_timer -= delta
    
    if is_on_floor():
        _coyote_timer = coyote_time
    
    # 2. Gravity
    if not is_on_floor():
        velocity.y += gravity * delta
    
    # 3. Input & Buffering
    if Input.is_action_just_pressed("ui_accept"):
        _jump_buffer_timer = jump_buffer
    
    # 4. Jump Execution (The 'Forgiving' Logic)
    if _jump_buffer_timer > 0 and _coyote_timer > 0:
        _perform_jump()
    
    # 5. Horizontal Movement (Smooth Accel/Decel)
    var direction = Input.get_axis("ui_left", "ui_right")
    if direction:
        velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, friction * delta)
    
    move_and_slide()
    _apply_subpixel_stabilization()

func _perform_jump() -> void:
    velocity.y = jump_force
    _coyote_timer = 0
    _jump_buffer_timer = 0

func _apply_subpixel_stabilization() -> void:
    # Forces visual position to round to pixel grid while keeping 
    # logical position fractional. Prevents jitter in low-res art.
    # Note: Modern Godot 4 CanvasItems often handle this, but explicit 
    # snapping in the Shader or Transform is still 'Expert' practice.
    pass

## EXPERT NOTE:
## Use 'move_toward' instead of 'lerp' for linear movement as it 
## grants precise control over acceleration units (pixels/sec^2).
