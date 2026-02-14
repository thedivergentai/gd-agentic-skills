> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Ability Systems**. Accessed via Godot Master.

# Ability System

Expert guidance for building flexible, extensible ability systems with cooldowns, resource management, and complex skill trees.

## Available Scripts

### [ability_manager.gd](../scripts/godot-ability-system_ability_manager.gd)
Centralized ability orchestration. Handles registration, cooldown tracking (including Global Cooldown), cast timing, and resource consumption checks.

### [ability_resource.gd](../scripts/godot-ability-system_ability_resource.gd)
Base `Resource` class for scriptable abilities. Contains metadata (name, icon, cost) and virtual execution methods for specialized ability types.


## NEVER Do

- **NEVER use `_process()` for cooldown timing** — Always use `_physics_process()` or dedicated `Timer` nodes to avoid desync caused by variable frame deltas.
- **NEVER skip Global Cooldown (GCD)** — Instant-cast spam ruins game balance. Implement a small (0.5s - 1.0s) universal delay between all ability triggers.
- **NEVER hardcode ability logic in a central manager** — Use the **Strategy Pattern**. Each ability should be a standalone resource that knows how to execute itself.
- **NEVER allow ability triggers during animation locks** — Always check a "casting" flag or the `is_playing()` status of your animation state before allowing a cast.
- **NEVER save cooldown state as "time remaining"** — Save an absolute timestamp (`OS.get_unix_time() + remaining`) to prevent clock-based exploits.

---

## Architecture Pattern: Resource-Based Abilities
The system relies on `Ability` resources. Each unique ability (e.g., Fireball, Dash) is a distinct `.tres` file. This allows designers to swap abilities and tweak stats without touching core character code.

## Ability Execution Workflow
1. **Request**: Caster calls `use_ability(id)`.
2. **Validation**: Manager checks Cooldown, GCD, and Resource (Mana/Stamina/Health) costs.
3. **Consumption**: Resources are deducted immediately.
4. **Casting**: If `cast_time > 0`, the manager starts a timer and sets `is_casting = true`.
5. **Execution**: On timer completion, `ability.execute()` is triggered.

## Combo Systems
Implement a `ComboTracker` that stores a history of recently used ability IDs. If a specific sequence is detected within a valid time window, trigger a powerful "Finisher" or hidden ability.

## Skill Tree Management
Organize abilities into `SkillNode` resources. Each node tracks prerequisites, rank, and unlock status. The `SkillTree` manager validates unlock requirements (player level, skill points) before granting new abilities.

## Persistence
For save games, store active cooldowns as absolute system timestamps to ensure they continue counting down accurately upon reload.

## Reference
- [Godot Docs: Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot Docs: Timers](https://docs.godotengine.org/en/stable/classes/class_timer.html)
