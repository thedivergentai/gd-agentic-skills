# Procedural Squash and Stretch for Godot 2D
extends Sprite2D

@export var squash_stretch_rate := 10.0
@export var impact_threshold := 500.0

var _base_scale: Vector2
var _target_scale: Vector2

func _ready() -> void:
	_base_scale = scale
	_target_scale = scale

func _process(delta: float) -> void:
	# Continuous smoothing toward target or base
	scale = scale.lerp(_target_scale, squash_stretch_rate * delta)
	_target_scale = _target_scale.lerp(_base_scale, squash_stretch_rate * delta)

## Calculate deformation based on velocity.
## Call this in _physics_process before move_and_slide for stretching,
## or immediately after a collision impact for squashing.
func apply_velocity_deformation(velocity: Vector2, max_velocity: float = 1000.0) -> void:
	var speed_ratio := clamp(velocity.length() / max_velocity, 0.0, 1.0)
	# Stretch along the move axis, squash the perpendicular
	_target_scale = _base_scale * Vector2(1.0 - speed_ratio * 0.2, 1.0 + speed_ratio * 0.4)
	# Orient the sprite to face the movement for directional stretch
	rotation = velocity.angle() + PI/2

func apply_impact_squash(impact_velocity: float) -> void:
	if abs(impact_velocity) < impact_threshold:
		return
	
	var strength := clamp(abs(impact_velocity) / 2000.0, 0.0, 0.5)
	# Sudden squash: wide and short
	scale = _base_scale * Vector2(1.0 + strength, 1.0 - strength)
	_target_scale = _base_scale
