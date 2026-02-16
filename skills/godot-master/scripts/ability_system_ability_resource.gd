# godot-master/scripts/ability_system_ability_resource.gd
extends Resource
class_name AbilityResource

## Scriptable Ability Resource Expert Pattern
## Defines the data and logic for a single ability/skill.

@export_group("Metadata")
@export var ability_name: String = "New Ability"
@export var description: String = ""
@export var icon: Texture2D

@export_group("Stats")
@export var cooldown: float = 1.0
@export var energy_cost: int = 0
@export var is_passive: bool = false

@export_group("Effects")
## List of Effect resources to apply on execution
@export var effects: Array[Resource] 

## --- Expert Execution Logic ---
## Instead of hardcoding logic, we use a virtual function that 
## the AbilityManager calls.

func execute(user: Node2D, target_position: Vector2) -> bool:
    # 1. Verification (Energy/Requirements)
    # 2. Logic Implementation (can be overridden in inherited scripts)
    print_debug("Executing ability: ", ability_name)
    
    # Example: Spawn effects
    for effect in effects:
        if effect.has_method("apply"):
            effect.apply(user, target_position)
            
    return true

## EXPERT NOTE:
## Create specialized inherited resources for different types of abilities:
## - ProjectileAbility.gd (Overwrites execute to spawn an object)
## - BuffAbility.gd (Overwrites execute to apply a modifier)
## This follows 'Composition over Inheritance' at the data layer.
