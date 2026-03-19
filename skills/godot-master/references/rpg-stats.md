---
name: godot-rpg-stats
description: "Expert blueprint for RPG stat systems (attributes, leveling, modifiers, damage formulas) using Resource-based stats, stackable modifiers, and derived stat calculations. Use when implementing character progression OR equipment/buff systems. Keywords stats, attributes, leveling, modifiers, CharacterStats, derived stats, damage calculation, XP."
---

# RPG Stats

Resource-based stats, modifier stacks, and derived calculations define flexible character progression.

## Available Scripts

### [base_stats_resource.gd](../scripts/rpg_stats_base_stats_resource.gd)
Core data container for base attributes (Str, Dex, Int) and derived scaling rules.

### [status_effect_data.gd](../scripts/rpg_stats_status_effect_data.gd)
Serialized data definition for buffs/debuffs (Additive, Multiplicative, Override).

### [stats_component_reactive.gd](../scripts/rpg_stats_stats_component_reactive.gd)
Orchestrator for JIT (Just-In-Time) stat calculation with active modifier stacking.

### [exp_progression_resource.gd](../scripts/rpg_stats_exp_progression_resource.gd)
Data-driven level-up curve definition using growth factors and base XP.

### [dynamic_stat_label_sync.gd](../scripts/rpg_stats_dynamic_stat_label_sync.gd)
Reactive UI hook for syncing Labels to stat changes without polling.

### [damage_formula_handler.gd](../scripts/rpg_stats_damage_formula_handler.gd)
Centralized RefCounted utility for complex combat math and damage calculations.

### [stat_modifier_stacking.gd](../scripts/rpg_stats_stat_modifier_stacking.gd)
Logic for handling unique vs. stackable buffs and refreshing durations.

### [resource_stat_inheritance.gd](../scripts/rpg_stats_resource_stat_inheritance.gd)
Pattern for extending base stats with specialized attributes (Elemental Resists).

### [persistent_character_stats.gd](../scripts/rpg_stats_persistent_character_stats.gd)
Managing the serialization of character progression to `.tres` files.

### [level_up_system.gd](../scripts/rpg_stats_level_up_system.gd)
Logic for awarding experience and triggering level-up benefits.

## NEVER Do in RPG Stats

- **NEVER use integers for percentages** — `critical_chance = 50`? Integer division (e.g., in formulas) causes truncation. Always use `float` (0.0 to 1.0 or 0.0 to 100.0) [20].
- **NEVER modify current_health without emitting signals** — UI elements like health bars will desync if you don't broadcast changes to the system [21].
- **NEVER rely solely on additive modifiers** — +10 strength is huge at level 1 but negligible at level 50. Use multiplicative or hybrid scaling for balance [22].
- **NEVER add modifiers without a unique ID or Key** — Without a reference (e.g., "potion_buff"), you cannot remove specific effects without clearing the entire stack [23].
- **NEVER use exponential XP formulas without a growth cap** — Uncapped `pow()` scaling quickly leads to unreachable levels or integer overflows [24].
- **NEVER forget to clamp derived values** — Negative vitality from a debuff could result in negative max HP, crashing your health logic. Use `maxi(val, 1)` [25].
- **NEVER perform heavy stat recalculations in `_process()`** — Only recalculate when a modifier is added/removed or base stats change. Use the "Reactive" pattern.
- **NEVER hardcode stat names in logic** — Use StringNames or an Enum for attributes to prevent typos and facilitate refactoring (e.g., `get_attribute("strength")`).
- **NEVER store temporary "Runtime Only" buffs in a permanent Save Resource** — Clear short-duration modifiers before serializing player progress to disk.
- **NEVER calculate damage directly in the Character script** — Centralize combat math in a `DamageFormula` class to ensure consistency across Players and NPCs.

---

```gdscript
# stats.gd
class_name Stats
extends Resource

signal stat_changed(stat_name: String, old_value: float, new_value: float)
signal level_up(new_level: int)

@export var level: int = 1
@export var experience: int = 0
@export var experience_to_next_level: int = 100

# Base stats
@export var strength: int = 10
@export var dexterity: int = 10
@export var intelligence: int = 10
@export var vitality: int = 10

# Derived stats (calculated from base)
var max_health: int:
    get: return vitality * 10
var attack_power: int:
    get: return strength * 2
var defense: int:
    get: return strength + (vitality / 2)
var magic_power: int:
    get: return intelligence * 3
var critical_chance: float:
    get: return dexterity * 0.01

# Modifiers
var modifiers: Dictionary = {}

func add_experience(amount: int) -> void:
    experience += amount
    
    while experience >= experience_to_next_level:
        level_up_character()

func level_up_character() -> void:
    level += 1
    experience -= experience_to_next_level
    experience_to_next_level = int(experience_to_next_level * 1.5)
    
    # Increase base stats
    strength += 2
    dexterity += 2
    intelligence += 2
    vitality += 2
    
    level_up.emit(level)

func get_stat(stat_name: String) -> float:
    var base_value: float = get(stat_name)
    var modifier_bonus := get_modifier_total(stat_name)
    return base_value + modifier_bonus

func add_modifier(stat_name: String, modifier_id: String, value: float) -> void:
    if not modifiers.has(stat_name):
        modifiers[stat_name] = {}
    
    modifiers[stat_name][modifier_id] = value

func remove_modifier(stat_name: String, modifier_id: String) -> void:
    if modifiers.has(stat_name):
        modifiers[stat_name].erase(modifier_id)

func get_modifier_total(stat_name: String) -> float:
    if not modifiers.has(stat_name):
        return 0.0
    
    var total := 0.0
    for value in modifiers[stat_name].values():
        total += value
    return total
```

## Equipment Stats

```gdscript
# equipment_item.gd
extends Item
class_name EquipmentItem

@export var stat_bonuses: Dictionary = {
    "strength": 5,
    "dexterity": 3
}

func on_equip(stats: Stats) -> void:
    for stat_name in stat_bonuses:
        stats.add_modifier(stat_name, "equipment_" + id, stat_bonuses[stat_name])

func on_unequip(stats: Stats) -> void:
    for stat_name in stat_bonuses:
        stats.remove_modifier(stat_name, "equipment_" + id)
```

## Status Effects

```gdscript
# status_effect.gd
class_name StatusEffect
extends Resource

@export var effect_id: String
@export var duration: float
@export var stat_modifiers: Dictionary = {}

func apply(stats: Stats) -> void:
    for stat_name in stat_modifiers:
        stats.add_modifier(stat_name, "status_" + effect_id, stat_modifiers[stat_name])

func remove(stats: Stats) -> void:
    for stat_name in stat_modifiers:
        stats.remove_modifier(stat_name, "status_" + effect_id)
```

## Damage Calculation

```gdscript
func calculate_damage(attacker_stats: Stats, defender_stats: Stats) -> float:
    var base_damage := float(attacker_stats.attack_power)
    var defense := float(defender_stats.defense)
    
    # Damage reduction formula
    var damage := base_damage * (100.0 / (100.0 + defense))
    
    # Critical hit
    if randf() < attacker_stats.critical_chance:
        damage *= 2.0
    
    return maxf(damage, 1.0)  # Minimum 1 damage
```

## Skill Requirements

```gdscript
# skill.gd
class_name Skill
extends Resource

@export var required_level: int = 1
@export var required_stats: Dictionary = {
    "strength": 15,
    "intelligence": 10
}

func can_use(stats: Stats) -> bool:
    if stats.level < required_level:
        return false
    
    for stat_name in required_stats:
        if stats.get_stat(stat_name) < required_stats[stat_name]:
            return false
    
    return true
```

## Best Practices

1. **Derived Stats** - Calculate from base stats
2. **Modifiers** - Temporary/permanent bonuses
3. **Formula Balance** - Avoid exponential power creep

## Reference
- Related: `godot-combat-system`, `godot-inventory-system`


### Related
- Master Skill: [godot-master](../SKILL.md)
