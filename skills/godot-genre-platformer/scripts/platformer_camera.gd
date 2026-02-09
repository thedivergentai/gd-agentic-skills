# skills/genre-platformer/scripts/platformer_camera.gd
extends Camera2D

## Platformer Camera Expert Pattern
## "Look Ahead" camera that smooths movement and anticipates player direction.

class_name PlatformerCamera

@export var target: Node2D
@export var look_ahead_dist: float = 100.0
@export var lerp_speed: float = 3.0
@export var vertical_offset: float = -50.0

var _current_look_ahead_x: float = 0.0

func _physics_process(delta: float) -> void:
    if not target: return
    
    # 1. Base Position
    var target_pos = target.global_position
    target_pos.y += vertical_offset
    
    # 2. Look Ahead Logic
    if target is CharacterBody2D:
        var v_x = target.velocity.x
        if abs(v_x) > 10.0:
            var dir = sign(v_x)
            _current_look_ahead_x = lerp(_current_look_ahead_x, dir * look_ahead_dist, lerp_speed * delta)
        else:
             # Center when stopped
             _current_look_ahead_x = lerp(_current_look_ahead_x, 0.0, lerp_speed * delta)
    
    target_pos.x += _current_look_ahead_x
    
    # 3. Position Smoothing (or use Camera2D built-in)
    # We apply manually for more control if position_smoothing is off
    global_position = global_position.lerp(target_pos, 5.0 * delta)

## EXPERT USAGE:
## Assign Player to 'target'. Ensure Camera2D is NOT child of player 
## (or use RemoteTransform2D) to avoid jitter.
