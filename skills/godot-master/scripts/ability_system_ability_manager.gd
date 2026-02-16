# godot-master/scripts/ability_system_ability_manager.gd
extends Node
class_name AbilityManager

## Ability Manager Expert Pattern
## Orchestrates ability execution, cooldown stacks, and energy consumption.

@onready var owner_node: Node2D = get_parent()

# Persistent state for cooldowns
# Mapping: AbilityResource (or its name) -> Timestamp of next available use
var _cooldown_registry: Dictionary = {}

func can_use_ability(ability: AbilityResource) -> bool:
    var current_time := Time.get_ticks_msec() / 1000.0
    var next_available := _cooldown_registry.get(ability, 0.0)
    
    return current_time >= next_available

func use_ability(ability: AbilityResource, target_pos: Vector2) -> void:
    if not can_use_ability(ability):
        print("Ability on cooldown!")
        return
        
    # 1. Execute the resource logic
    var success := ability.execute(owner_node, target_pos)
    
    # 2. Start Cooldown on success
    if success:
        var current_time := Time.get_ticks_msec() / 1000.0
        _cooldown_registry[ability] = current_time + ability.cooldown

## EXPERT PATTERN: Cooldown Visuals
func get_cooldown_progress(ability: AbilityResource) -> float:
    if not _cooldown_registry.has(ability): return 1.0
    
    var current_time := Time.get_ticks_msec() / 1000.0
    var next_available := _cooldown_registry[ability]
    var remaining := next_available - current_time
    
    if remaining <= 0: return 1.0
    return 1.0 - (remaining / ability.cooldown)

## WHY THIS WAY?
## This manager is completely decoupled from the specific 'Character' logic.
## It can be attached to Players, Enemies, or even Turrets.
