> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Turn Systems**. Accessed via Godot Master.

# Turn System

Expert blueprint for turn-based combat, including Active Time Battle (ATB), initiative-based queues, and action point management.

## Available Scripts

### [active_time_battle.gd](../scripts/turn_system_active_time_battle.gd)
Framework for ATB systems. Manages dynamic progress bars for unit initiative and handles async action execution during active combat.

### [timeline_turn_manager.gd](../scripts/turn_system_timeline_turn_manager.gd)
Advanced manager for timeline-based turns. Supports turn interrupts, simultaneous unit actions, and predictive turn order visualization.


## NEVER Do

- **NEVER recalculate turn order on every single action** — Sorting a large array of combatants repeatedly is inefficient. Calculate the order once per round, or update only when a unit's speed stat changes.
- **NEVER use random tie-breaking for initiative** — Two units with the same speed should not have their turn order determined randomly, as this makes game states non-deterministic and hard to debug. Use a secondary stat (e.g., Agility) or unique ID as a tie-breaker.
- **NEVER deduct Action Points (AP) before validation** — Always check `can_perform_action(cost)` before applying changes. Logic like `current_ap -= cost` without a check will lead to negative AP values and exploits.
- **NEVER hardcode combat phase transitions** — Chaining phases like `if phase == 0: phase = 1` is fragile. Use an `enum` + `match` statement or a dedicated State Machine to orchestrate transitions between Draw, Main, and End phases.
- **NEVER emit "Turn Ended" before internal cleanup** — Ensure AP is reset, status effect durations are ticked down, and temporary buffs are cleared before signaling the next turn to begin.

---

## Turn Order Strategies
1. **Round-Based**: All units act once per round. Order is determined at round start by a `speed` stat.
2. **Dynamic Initiative (ATB)**: Each unit has a fill bar. When the bar is full, the unit acts. Speed determines how fast the bar fills.
3. **Action Point (AP) Spending**: Units spend points from a pool. Turn ends when AP is exhausted or the player manually passes.

## Phase Orchestration
Common turn phases:
- **Upkeep**: Tick status effects (poison, regen).
- **Draw/Resource**: Gain AP or cards.
- **Action**: Player or AI selects and executes moves.
- **End**: Post-action triggers and state cleanup.

## Advanced: Interruption & Simultaneous Turns
- **Interrupts**: Allow a unit with a specific ability or high initiative to "jump" the queue.
- **Simultaneous**: Multiple units are assigned tiles/actions simultaneously, and all actions execute in a single resolved animation phase.

## NPC AI Integration
Plug your AI logic into the `turn_started` signal. When it's an NPC's turn, trigger their decision-making tree and call `TurnManager.end_turn()` once the action's associated animation has completed.

## Reference
- [Godot Docs: Finite State Machines](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot Docs: Array Sorting](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-sort-custom)
