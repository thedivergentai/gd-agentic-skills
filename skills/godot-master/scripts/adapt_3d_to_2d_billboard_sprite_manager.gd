extends CharacterBody2D
class_name BillboardSpriteManager

## Expert 2D Sprite Animator simulating 3D Camera Angles
## Used in "Doom-style" FPS or 2.5D games.
## Chooses the correct animation frame based on viewing angle between actor and camera.

@export var sprite: AnimatedSprite2D
@export var simulated_camera: Camera2D 

func _process(_delta: float) -> void:
    _update_facing_angle()

func _update_facing_angle() -> void:
    # Vector from us to camera
    var dir_to_cam = global_position.direction_to(simulated_camera.global_position)
    
    # The direction the character is actually looking/moving
    var facing_dir = velocity.normalized() if velocity.length() > 0 else Vector2.RIGHT
    
    # Get angle between facing direction and camera view
    var angle_diff = facing_dir.angle_to(dir_to_cam)
    
    # Map from -PI to PI into 8 discrete indices (0-7)
    var octant = int(snapped(rad_to_deg(angle_diff) + 180, 45) / 45) % 8
    
    var animation_names = [
        "idle_front", "idle_front_right", "idle_right", "idle_back_right", 
        "idle_back", "idle_back_left", "idle_left", "idle_front_left"
    ]
    
    sprite.play(animation_names[octant])
