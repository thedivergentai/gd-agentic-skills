# godot-master/scripts/adapt_3d_2d_ortho_simulation.gd
extends CharacterBody2D

## Ortho Simulation Expert Pattern
## Simulates 3D mechanics (gravity, jump, shadow) in a 2D top-down view.

class_name OrthoSimulation

@export var jump_height: float = 50.0 # Pixels
@export var jump_duration: float = 0.5 # Seconds
@export var base_scale: float = 1.0

# Nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Sprite2D = $Shadow # Must be separate child

# State
var _z_height: float = 0.0
var _z_velocity: float = 0.0
var _gravity: float
var _jump_impulse: float

func _ready() -> void:
    # Calculate gravity physics based on desired jump arc
    _gravity = (2.0 * jump_height) / pow(jump_duration / 2.0, 2)
    _jump_impulse = sqrt(2.0 * _gravity * jump_height)

func _physics_process(delta: float) -> void:
    # 1. 3D Z-Axis Simulation
    if _z_height > 0 or _z_velocity > 0:
        _z_velocity -= _gravity * delta
        _z_height += _z_velocity * delta
        
        if _z_height <= 0:
            _z_height = 0
            _z_velocity = 0
            _on_land()
    
    # 2. Visual Offset (Y-axis displacement)
    # in 2.5D, Y-up typically maps to -Y in 2D
    sprite.position.y = -_z_height
    
    # 3. Dynamic Shadow Scaling
    # Shadow stays on "ground" (local 0,0), shrinks as unit jumps high
    var shadow_scale = 1.0 - clamp(_z_height / (jump_height * 2.0), 0.0, 0.5)
    shadow.scale = Vector2.ONE * shadow_scale * base_scale

    # Input & Movement (Standard 2D)
    var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input * 200.0
    move_and_slide()

    if Input.is_action_just_pressed("ui_accept") and _z_height == 0:
        jump()

func jump() -> void:
    _z_velocity = _jump_impulse

func _on_land() -> void:
    # Landing particles, sound, etc.
    pass

## EXPERT USAGE:
## Sprite2D must be child. Shadow must be child (and below sprite).
## Simulates "Z-Jump" in top-down games like Zelda/CrossCode.
