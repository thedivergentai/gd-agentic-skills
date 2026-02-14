> [!NOTE]
> **Resource Context**: This module provides expert patterns for **RPG Stats**. Accessed via Godot Master.

# RPG Stats

Expert blueprint for character attributes, leveling systems, and stackable stat modifiers using decoupled resource patterns.

## Available Scripts

### [stat_resource.gd](../scripts/godot-rpg-stats_stat_resource.gd)
Robust Resource-based foundation for individual stats. Includes smart caching, dirty flags to prevent redundant recalculations, and modifier stack support.

### [modifier_stack_stats.gd](../scripts/godot-rpg-stats_modifier_stack_stats.gd)
Advanced stat container supporting additive and multiplicative modifiers. Handles priority ordering and complex attribute dependencies.


## NEVER Do

- **NEVER use `int` for percentage-based modifiers** — Integer division (`50/100 = 0`) causes truncation. Always use `float` (0.0 to 1.0) for ratios and percentages.
- **NEVER modify stat values without emitting signals** — The UI and combat logic will stay desynced if you don't broadcast changes. Connect your health bars and damage numbers to `stat_changed` signals.
- **NEVER rely exclusively on additive modifiers** — Adding +10 at high levels is useless. Use multiplicative modifiers (e.g., +10% base) to ensure buffs remain relevant across the entire game progression.
- **NEVER add modifiers without a unique ID** — Using anonymous modifiers makes it impossible to remove specific buffs or items later. Always associate modifiers with a unique source (e.g., `"poison_debuff"`, `"excalibur_bonus"`).
- **NEVER forget to clamp derived stats** — A debuff should never cause `max_health` or `defense` to drop below 0 (or 1), as this can break damage formulas and cause crashes.

---

## Core Pattern: Base vs. Derived Stats
1. **Base Stats**: Primary attributes (Strength, Dexterity, Vitality) that the player directly increases upon leveling up.
2. **Derived Stats**: Values calculated from base stats (e.g., `MaxHealth = Vitality * 10`). These should be computed properties that update when the underlying base stats change.

## Modifier Stacks
The system calculates the final value using:
`Final = (Base + AdditiveSum) * MultiplierProduct`
This ensures that buffs from multiple sources (equipment, potions, passive skills) interact predictably.

## Leveling & Experience
Use an XP curve (linear, logarithmic, or table-based). When `experience >= experience_to_next_level`, increment the level, increase base attributes, and emit a `level_up` signal. Avoid extreme exponential growth that makes high-level balancing impossible.

## Damage Formulas
Standard RPG mitigation formula:
`Damage = RawAttack * (100 / (100 + Armor))`
This provides diminishing returns on high armor values, preventing players from becoming truly immortal.

## Equipment Integration
When equipping an item, call `add_modifier()` on the character's `Stats` resource. When unequipping, call `remove_modifier()` using the item's unique instance ID to ensure only that specific bonus is removed.

## Reference
- [Godot Docs: Setters and Getters](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#setters-and-getters)
- [Godot Docs: Random Number Generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html)
