# persistent_progression_system.gd
extends Node

# Persistent Progression Autoload (Singleton Pattern)
# Tracks unlocked abilities across room transitions using Signal architecture.

signal ability_unlocked(ability_name: StringName)

# Use StringName for optimized dictionary keys.
var _unlocked_abilities: Dictionary[StringName, bool] = {
    &"double_jump": false,
    &"wall_climb": false,
    &"dash": false
}

func unlock_ability(ability: StringName) -> void:
    _unlocked_abilities[ability] = true
    ability_unlocked.emit(ability)

func has_ability(ability: StringName) -> bool:
    # Safe retrieval with fallback.
    return _unlocked_abilities.get(ability, false)
