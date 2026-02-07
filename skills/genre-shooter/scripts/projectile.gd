# skills/genre-shooter/scripts/projectile.gd
extends CharacterBody3D

## Projectile Expert Pattern
## Physical bullet with gravity, bounce, and lifetime management.

class_name Projectile

@export var speed: float = 50.0
@export var damage: int = 25
@export var gravity_scale: float = 1.0
@export var max_lifetime: float = 5.0
@export var bounces: int = 0

var _velocity: Vector3 = Vector3.ZERO
var _timer: float = 0.0

func setup(direction: Vector3, start_pos: Vector3) -> void:
    look_at_from_position(start_pos, start_pos + direction)
    _velocity = direction * speed

func _physics_process(delta: float) -> void:
    _timer += delta
    if _timer >= max_lifetime:
        queue_free()
        return
        
    # Gravity
    _velocity.y -= 9.8 * gravity_scale * delta
    
    velocity = _velocity
    var collision = move_and_collide(velocity * delta)
    
    if collision:
        _handle_collision(collision)

func _handle_collision(collision: KinematicCollision3D) -> void:
    var collider = collision.get_collider()
    
    if collider.has_method("take_damage"):
        collider.take_damage(damage)
        queue_free()
    
    elif bounces > 0:
        bounces -= 1
        _velocity = _velocity.bounce(collision.get_normal())
        # Reflect visual
        look_at(global_position + _velocity)
    else:
        # Spawn impact effect
        queue_free()

## EXPERT USAGE:
## Instantiate from WeaponController. Call setup().
