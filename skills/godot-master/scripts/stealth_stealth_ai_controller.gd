# godot-master/scripts/stealth_stealth_ai_controller.gd
extends CharacterBody3D

## Stealth AI Expert Pattern
## Implements Vision (Light-dependent), Hearing, and Alertness Meter.

enum State { IDLE, SUSPICIOUS, ALERT, COMBAT }
var current_state: State = State.IDLE

@export var detection_threshold: float = 100.0
var alertness_meter: float = 0.0

@onready var vision_cast: RayCast3D = $VisionCast
@onready var player: Node3D = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    var can_see = _check_vision()
    
    if can_see:
        # 1. Light-Dependent Detection Speed
        var light_level = _get_player_light_level()
        alertness_meter += delta * 50.0 * light_level
    else:
        # Cool down alertness
        alertness_meter -= delta * 10.0
        
    alertness_meter = clamp(alertness_meter, 0, detection_threshold)
    _update_state()

func _check_vision() -> bool:
    if not player: return false
    
    # 2. Field of View & Line of Sight
    var dir_to_player = player.global_position - global_position
    var angle = global_transform.basis.z.angle_to(dir_to_player)
    
    if angle < deg_to_rad(45.0): # 90 degree FOV
        vision_cast.target_position = vision_cast.to_local(player.global_position)
        vision_cast.force_raycast_update()
        return not vision_cast.is_colliding() # Assuming layer mask only hits world
        
    return false

func _get_player_light_level() -> float:
    # 3. Light Gem Logic
    # In an expert setup, the player calculates their own 'exposure' 
    # based on light probes or specific light overlaps.
    if player.has_method("get_light_exposure"):
        return player.get_light_exposure()
    return 1.0 # Default to fully visible

func on_sound_heard(sound_pos: Vector3, intensity: float) -> void:
    # 4. Hearing Implementation
    var dist = global_position.distance_to(sound_pos)
    if dist < intensity * 10.0:
        alertness_meter += intensity * 20.0
        # Investigate sound source
        # navigation_agent.target_position = sound_pos

func _update_state() -> void:
    if alertness_meter >= detection_threshold:
        current_state = State.ALERT
    elif alertness_meter > 10.0:
        current_state = State.SUSPICIOUS
    else:
        current_state = State.IDLE

## EXPERT NOTE:
## Use 'Composite Vision Cones'. A short, wide cone for immediate detection 
## and a long, narrow cone for peripheral SUSPICION.
## Use the 'Reaction Delay' pattern: AI should pause for 0.5s when first 
## spotting the player to give the player time to duck back into cover.
