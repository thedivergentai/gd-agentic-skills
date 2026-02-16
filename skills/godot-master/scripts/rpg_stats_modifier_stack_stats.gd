# godot-master/scripts/rpg_stats_modifier_stack_stats.gd
extends Node

## RPG Stats Expert Pattern
## Implements Reactive Updates and Additive/Multiplicative Modifiers.

signal stat_changed(stat_name: String, new_value: float)

# 1. Base Stat vs Modifier Pattern
# Expert logic: Treat Stats as Resources to allow easy sharing.
class Stat:
    var base_value: float = 0.0
    var modifiers_add: float = 0.0
    var modifiers_mult: float = 1.0 # 1.0 = 100% (No change)
    
    func get_total() -> float:
        # Standard RPG Formula: (Base + Additions) * Multipliers
        return (base_value + modifiers_add) * modifiers_mult

var stats: Dictionary = {
    "strength": Stat.new(),
    "agility": Stat.new(),
    "max_health": Stat.new()
}

func add_modifier(stat_name: String, amount: float, is_multiplier: bool = false) -> void:
    # 2. Modifier Stacking Logic
    if not stats.has(stat_name): return
    
    var stat = stats[stat_name]
    if is_multiplier:
        stat.modifiers_mult += amount
    else:
        stat.modifiers_add += amount
        
    # 3. Reactive Stat Updates
    # Notify UI components ONLY when specific stats change.
    stat_changed.emit(stat_name, stat.get_total())

func get_stat(stat_name: String) -> float:
    return stats[stat_name].get_total() if stats.has(stat_name) else 0.0

## EXPERT NOTE:
## Use 'Exponential XP Formulas': For leveling, use 
## 'floor(100 * pow(level, 1.5))' to create a smooth difficulty curve.
## For 'rpg-stats', implement 'Derived Stat Calculation': 
## 'attack_power = get_stat("strength") * 1.5 + get_stat("agility")'. 
## Hook this into the 'stat_changed' signal to update child stats 
## whenever a parent stat is modified.
## NEVER allow direct modification of 'max_health' variable; 
## always use the 'add_modifier' protocol to prevent 'Value Leakage'.
