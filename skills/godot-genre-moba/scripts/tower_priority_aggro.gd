# godot-master/scripts/moba_tower_priority_aggro.gd
extends Node2D

## Tower Priority Aggro Expert Pattern
## Implementation of a "Priority Stack" for target selection.

@onready var detector = $AggroArea
var current_target: Node2D = null

func _physics_process(_delta: float) -> void:
    var potential_targets = detector.get_overlapping_bodies()
    var best_target = _evaluate_targets(potential_targets)
    
    if best_target != current_target:
        current_target = best_target
        _on_target_switched()

func _evaluate_targets(targets: Array) -> Node2D:
    # 1. Priority Stack Logic
    # 1st: Enemy heroes hitting an allied hero under tower.
    # 2nd: Enemy minions/units closest to the tower.
    # 3rd: Enemy heroes.
    
    var heroes_hitting_allies = []
    var minions = []
    var other_heroes = []
    
    for t in targets:
        if t.is_in_group("hero"):
            if t.get("is_attacking_ally"): heroes_hitting_allies.append(t)
            else: other_heroes.append(t)
        elif t.is_in_group("minion"):
            minions.append(t)
            
    if not heroes_hitting_allies.is_empty(): return _get_closest(heroes_hitting_allies)
    if not minions.is_empty(): return _get_closest(minions)
    return _get_closest(other_heroes)

func _get_closest(targets: Array) -> Node2D:
    var closest = null
    var min_dist = INF
    for t in targets:
        var d = global_position.distance_to(t.global_position)
        if d < min_dist:
            min_dist = d
            closest = t
    return closest

func _on_target_switched() -> void:
    if current_target:
        print("Tower Aggro: ", current_target.name)
        # Visual targeting line/laser update here

## EXPERT NOTE:
## Use Server-Side validation for 'is_attacking_ally'. 
## Damage calculation and target switching must be deterministic.
