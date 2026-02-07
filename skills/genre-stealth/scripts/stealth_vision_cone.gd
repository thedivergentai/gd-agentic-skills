# skills/genre-stealth/scripts/stealth_vision_cone.gd
extends Area3D

## Stealth Vision Cone (Expert Pattern)
## Implements realistic vision with composite FOV (focused vs peripheral).
## Uses Dot Product and Raycasts for performance (avoids huge Area3D checks).

class_name StealthVisionCone

signal playback_alert(level: float) # 0.0 to 1.0

@export var head: Node3D # Eyes position
@export var vision_range: float = 20.0
@export var peripheral_angle: float = 120.0 # Degrees
@export var focused_angle: float = 45.0
@export var detection_speed: float = 0.5 # Per second

var detection_level: float = 0.0
var target: Node3D # The player

func _ready() -> void:
    # Optimization: Only check player
    target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    if not target: return
    
    var player_visible = false
    var detection_rate = 0.0
    
    var to_target = target.global_position - head.global_position
    var dist_sq = to_target.length_squared()
    
    if dist_sq < vision_range * vision_range:
        var forward = head.global_transform.basis.z
        var dir_to_target = to_target.normalized()
        var dot = forward.dot(dir_to_target)
        var angle = rad_to_deg(acos(dot))
        
        # 1. Check Focused Vision (Fast detection)
        if angle < focused_angle / 2.0:
            if _has_line_of_sight(target):
                detection_rate = 1.5
                player_visible = true
                
        # 2. Check Peripheral Vision (Slow detection)
        elif angle < peripheral_angle / 2.0:
            if _has_line_of_sight(target):
                detection_rate = 0.5
                player_visible = true
    
    # 3. Update Meter
    if player_visible:
        # Distance scaling: faster if closer
        var dist_factor = 1.0 - (sqrt(dist_sq) / vision_range)
        detection_level += detection_speed * detection_rate * dist_factor * delta * 5.0
    else:
        detection_level -= delta * 0.5 # Cool down
        
    detection_level = clamp(detection_level, 0.0, 100.0)
    playback_alert.emit(detection_level)

func _has_line_of_sight(obj: Node3D) -> bool:
    var space = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(head.global_position, obj.global_position + Vector3(0, 1, 0)) # Chest height
    # Mask should exclude self and triggers, include world and player
    query.collision_mask = 1 | 2 # Example layers
    
    var result = space.intersect_ray(query)
    if result and result.collider == obj:
        return true
    return false

## EXPERT USAGE:
## Attach to Enemy Head. Assign 'Target' via group or inspector.
