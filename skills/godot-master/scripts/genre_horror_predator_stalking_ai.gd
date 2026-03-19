# godot-master/scripts/horror_predator_stalking_ai.gd
extends CharacterBody2D

## Predator Stalking AI Expert Pattern
## AI that maintains pursuit while actively avoiding the player's view cone.

@export var player: CharacterBody2D
@export var stalking_distance: float = 300.0
@export var movement_speed: float = 100.0

func _physics_process(_delta: float) -> void:
    if not player: return
    
    var dir_to_player = global_position.direction_to(player.global_position)
    var dist_to_player = global_position.distance_to(player.global_position)
    
    # 1. Line of Sight (LOS) Check
    var is_player_looking = _check_if_player_is_looking()
    
    var target_pos = global_position
    
    if is_player_looking:
        # 2. Hide/Retreat Pattern
        # Move toward a position that is outside the player's view cone or behind cover.
        target_pos = _find_hiding_spot()
    else:
        # 3. Follow/Stalk Pattern
        if dist_to_player > stalking_distance:
            target_pos = player.global_position - (dir_to_player * (stalking_distance * 0.8))
            
    velocity = global_position.direction_to(target_pos) * movement_speed
    move_and_slide()

func _check_if_player_is_looking() -> bool:
    # Check if the AI is within the player's forward cone (e.g. 60 degrees)
    var player_forward = -player.global_transform.y # Assuming Y-up/Forward in 2D
    var dir_to_ai = player.global_position.direction_to(global_position)
    var dot = player_forward.dot(dir_to_ai)
    return dot > 0.5 # Within ~60 degree cone

func _find_hiding_spot() -> Vector2:
    # Simplified: Move perpendicular to the player's view to get out of sight quickly.
    var player_forward = -player.global_transform.y
    var side_dir = Vector2(-player_forward.y, player_forward.x)
    return global_position + (side_dir * 100.0)

## EXPERT NOTE:
## For true 'Stalking' feel, use NavigationRegion2D to find points that 
## have NO occlusion to the player, but are within a specific distance.
