# skills/genre-tower-defense/code/tower_targeting_system.gd
extends Node3D

## Tower Targeting Expert Pattern
## Implements Projectile Prediction (Leading) and Priority Modes.

enum Priority { FIRST, LAST, STRONGEST, WEAKEST }
@export var target_priority: Priority = Priority.FIRST
@export var range: float = 10.0
@export var projectile_speed: float = 20.0

var _current_target: Node3D = null

func _process(_delta: float) -> void:
    _update_target()
    if _current_target:
        _aim_at_target()

func _update_target() -> void:
    var enemies = get_tree().get_nodes_in_group("enemies")
    var potential_targets = []
    
    for enemy in enemies:
        var dist = global_position.distance_to(enemy.global_position)
        if dist <= range:
            potential_targets.append(enemy)
            
    if potential_targets.is_empty():
        _current_target = null
        return
        
    # 1. Targeting Priority Logic
    match target_priority:
        Priority.FIRST:
            # Assumes enemies have a 'progress' property from PathFollow3D
            potential_targets.sort_custom(func(a, b): return a.progress > b.progress)
        Priority.STRONGEST:
            potential_targets.sort_custom(func(a, b): return a.health > b.health)
        # Add LAST and WEAKEST similarly
        
    _current_target = potential_targets[0]

func _aim_at_target() -> void:
    # 2. Projectile Prediction (Leading the Target)
    var target_pos = _current_target.global_position
    var target_vel = _current_target.velocity if "velocity" in _current_target else Vector3.ZERO
    
    var dist = global_position.distance_to(target_pos)
    var time_to_impact = dist / projectile_speed
    
    var predicted_pos = target_pos + (target_vel * time_to_impact)
    
    # Smoothly look at predicted position
    var target_basis = Basis.looking_at(predicted_pos - global_position)
    global_basis = global_basis.slerp(target_basis, 0.1)

## EXPERT NOTE:
## For 'Mazing' TD games, use an A* check before allowing tower placement. 
## If 'astar.get_id_path(start, end).is_empty()', the path is blocked—REFUSE placement.
## Use 'NavigationServer3D' for enemy movement to automatically handle 
## complex paths around player-built mazes without per-frame pathfinding costs.
