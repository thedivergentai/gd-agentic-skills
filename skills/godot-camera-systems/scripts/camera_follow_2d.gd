extends Camera2D

## Expert Camera2D follow script with look-ahead prediction and deadzones.
## Attachment: Add as child of the level OR parent to player and set top_level = true.

@export_group("Targeting")
@export var target: Node2D
@export var look_ahead_enabled: bool = true
@export var look_ahead_distance: float = 120.0
@export var look_ahead_speed: float = 2.0

@export_group("Smoothing")
@export var follow_smoothing: float = 5.0
@export var velocity_smoothing: float = 2.0

var _target_velocity: Vector2 = Vector2.ZERO
var _last_target_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
    if not target:
        push_warning("CameraFollow2D: No target assigned.")
    
    # Enable built-in smoothing as base
    position_smoothing_enabled = true
    position_smoothing_speed = follow_smoothing

func _process(delta: float) -> void:
    if not target:
        return
        
    var target_pos = target.global_position
    
    if look_ahead_enabled:
        # Calculate target velocity if it's not a CharacterBody
        var current_velocity = (target_pos - _last_target_pos) / delta if delta > 0 else Vector2.ZERO
        if target is CharacterBody2D:
            current_velocity = target.get_real_velocity()
            
        _target_velocity = _target_velocity.lerp(current_velocity, velocity_smoothing * delta)
        _last_target_pos = target_pos
        
        # Apply look-ahead offset
        var offset_vec = _target_velocity.normalized() * look_ahead_distance
        target_pos += offset_vec
        
    global_position = target_pos

## Helper to set camera limits from a ColorRect or reference shape
func set_limits_from_rect(rect: Rect2) -> void:
    limit_left = int(rect.position.x)
    limit_top = int(rect.position.y)
    limit_right = int(rect.end.x)
    limit_bottom = int(rect.end.y)
