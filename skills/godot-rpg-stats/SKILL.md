---
name: godot-rpg-stats
description: "Expert blueprint for RPG stat systems (attributes, leveling, modifiers, damage formulas) using Resource-based stats, stackable modifiers, and derived stat calculations. Use when implementing character progression OR equipment/buff systems. Keywords stats, attributes, leveling, modifiers, CharacterStats, derived stats, damage calculation, XP."
---

# RPG Stats

Resource-based stats, modifier stacks, and derived calculations define flexible character progression.

## Available Scripts

### [stat_resource.gd](scripts/stat_resource.gd)
Robust Resource-based stat system with caching, dirty flags, and modifier stacks.

### [modifier_stack_stats.gd](scripts/modifier_stack_stats.gd)
Expert stat system with additive/multiplicative modifier stacks and priority ordering.

## NEVER Do in RPG Stats

- **NEVER use int for percentages** — `var critical_chance: int = 50` for 50%? Integer division = truncation errors. Use `float` (0.0-1.0 OR 0.0-100.0).
- **NEVER modify stats without signals** — UI showing health bar but `stats.current_health -= 10` doesn't update? MUST emit signals on stat changes.
- **NEVER use additive-only modifiers** — Buff adds +10 strength on level 1 (10 base) = 100% increase. Same buff on level 50 (100 base) = 10% increase. Use multiplicative OR hybrid.
- **NEVER skip modifier IDs** — `add_modifier("strength", 5)` without ID? Can't remove specific buffs later. MUST use unique IDs (e.g., "sword_buff", "potion_123").
- **NEVER use exponential XP formulas without cap** — `xp_to_next = level * 1000`? Level 100 = 100k XP, level 1000 = 1M. Use sqrt/log OR flat scaling.
- **NEVER forget to clamp derived stats** — `max_health = vitality * 10`? Negative vitality from debuff = negative health = crash. Use `maxi(value, 1)`.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)
