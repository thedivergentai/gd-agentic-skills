# skills/2d-physics/scripts/custom_physics_2d.gd
extends CharacterBody2D

## Custom Physics 2D (Expert Pattern)
## Template for platformers requiring custom gravity/dashing/states without FSM overhead.
## Demonstrates use of `move_and_slide` with external forces.

class_name CustomPhysics2D

@export var gravity: float = 980.0
@export var jump_force: float = -400.0
@export var speed: float = 300.0

var external_force: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
    # 1. Apply Gravity
    if not is_on_floor():
        velocity.y += gravity * delta
    else:
        velocity.y = 0.0 # Reset accum
        
    # 2. Input
    var dir = Input.get_axis("ui_left", "ui_right")
    if dir:
        velocity.x = dir * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed * delta * 5.0) # Friction
        
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_force
        
    # 3. Apply External Forces (Knockback)
    velocity += external_force * delta
    external_force = external_force.move_toward(Vector2.ZERO, 1000.0 * delta)
    
    # 4. Move
    move_and_slide()

func apply_knockback(force: Vector2) -> void:
    # Set immediate velocity? Or Add to external force?
    # Instant velocity change is usually snappier for hits
    velocity += force 

## EXPERT USAGE:
## Extend for PlayerController.
