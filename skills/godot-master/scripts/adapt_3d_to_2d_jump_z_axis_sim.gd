extends CharacterBody2D
class_name PlatformerTopDown2D

## Expert Z-Axis Simulator for Top-Down 2D Games
## Simulates a 3rd dimension (Jumping in a top-down game like Zelda)
## Separates physical collision (X/Y on the ground) from the visual Sprite (Z height).

@export var move_speed: float = 200.0
@export var jump_force: float = 300.0
@export var gravity: float = 980.0

var z_height: float = 0.0
var z_velocity: float = 0.0

@onready var visual_root: Node2D = $VisualRoot # Holds the sprite
@onready var shadow: Sprite2D = $Shadow

func _physics_process(delta: float) -> void:
    _handle_z_axis(delta)
    _handle_movement(delta)

func _handle_z_axis(delta: float) -> void:
    if z_height > 0 or z_velocity > 0:
        z_velocity -= gravity * delta
        z_height += z_velocity * delta
        
        # Hit the ground
        if z_height <= 0:
            z_height = 0.0
            z_velocity = 0.0
            
    # Jump input
    if Input.is_action_just_pressed("jump") and is_on_ground():
        z_velocity = jump_force

    # Apply to visuals (negative Y moves up on screen)
    visual_root.position.y = -z_height
    
    # Scale shadow based on height
    var scale_amount = remap(z_height, 0.0, 100.0, 1.0, 0.5)
    shadow.scale = Vector2(scale_amount, scale_amount)
    shadow.modulate.a = remap(z_height, 0.0, 100.0, 1.0, 0.2)
    
func _handle_movement(delta: float) -> void:
    var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input * move_speed
    move_and_slide()

func is_on_ground() -> bool:
    return is_zero_approx(z_height)
