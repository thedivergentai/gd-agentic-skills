# character_stats_resource.gd
extends Resource
class_name CharacterStatsResource

# Modular Resource-Based Character Stats
# Lightweight Inspector-friendly data container for RPG attributes.

@export var max_health: int = 100
@export var base_attack_damage: float = 15.0
@export var elemental_resistances: Dictionary[StringName, float] = {
    &"fire": 0.0,
    &"ice": 0.0,
    &"lightning": 0.0
}

# Methods allow for internal scaling logic without exposing math variables.
func get_scaled_damage(multiplier: float) -> float:
    return base_attack_damage * multiplier

func get_mitigated_damage(incoming_damage: float, element: StringName) -> float:
    var res = elemental_resistances.get(element, 0.0)
    return incoming_damage * (1.0 - res)
