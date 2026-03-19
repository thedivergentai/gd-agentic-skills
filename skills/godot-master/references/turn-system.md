---
name: godot-turn-system
description: "Expert blueprint for turn-based combat with turn order, action points, phase management, and timeline systems for strategy/RPG games. Covers speed-based initiative, interrupts, and simultaneous turns. Use when implementing turn-based combat OR tactical systems. Keywords turn-based, initiative, action points, phase, round, turn order, combat."
---

# Turn System

Turn order calculation, action points, phase management, and timeline systems define turn-based combat.

## NEVER Do (Expert Anti-Patterns)

### Order & Determinism
- NEVER recalculate turn order every action; strictly sort once per round or ONLY when a speed-relevant stat changes to prevent O(n log n) lag.
- NEVER use random tie-breaking for initiative; strictly use a secondary static attribute (Agility, ID, or persistent "luck") for **deterministic replays**.
- NEVER modify an active turn-order queue while iterating it; strictly iterate over a `duplicate()` or apply queue modifications after the loop.
- NEVER broadcast global turn state changes using immediate `call_group()`; strictly use **`call_group_flags(SceneTree.GROUP_CALL_DEFERRED, ...)`** to prevent frame spikes when notifying hundreds of units.
 
- NEVER rely on the Node hierarchy as the source of truth; strictly use a **Dictionary board state** for logical grid coordinates.

### Logic & Action Economy
- NEVER deduct Action Points (AP) before validation; strictly call `can_perform_action(cost)` before applying `current_ap -= cost` to prevent exploits.
- NEVER hardcode phase transitions (`if phase == 0`); strictly use an **enum + match** or a dedicated State Machine for Draw/Main/End phases.
- NEVER emit "Turn Ended" before internal cleanup; strictly reset AP and tick status effects **BEFORE** signaling the next turn.
- NEVER use exact floating-point equality (`==`) for AP checks; strictly use `>=` or `is_equal_approx()` for robust comparisons.

### Tactical Grid & UI
- NEVER use generic `AStar2D` for tile grids; strictly use **`AStarGrid2D`** for 10x faster pathfinding and native diagonal handling.
- NEVER forget to call **`update()`** on `AStarGrid2D` after changing obstacle states; if you toggle `set_point_solid()`, the grid MUST refresh before the next query.
- NEVER lock the main thread with `while` loops for input; strictly use the **await keyword** or signals to yield execution back to the Tree.
- NEVER handle turn decisions with `is_action_pressed()`; strictly use `is_action_just_pressed()` for discrete, frame-locked menu input.
- NEVER skip turn timeouts in networked games; strictly implement a **server-side timer** with a default "pass" action to prevent griefing.

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [active_time_battle.gd](../scripts/turn_system_active_time_battle.gd) - Framework for ATB systems with dynamic progress bars and async action support.
- [timeline_turn_manager.gd](../scripts/turn_system_timeline_turn_manager.gd) - Advanced manager for timeline-based turns with interrupts and predictive visualization.

### Modular Components
- [turn_system_patterns.gd](../scripts/turn_system_turn_system_patterns.gd) - Collection of patterns for match state machines, UndoRedo, and A* Grid setup.

---

```gdscript
# turn_manager.gd (AutoLoad)
extends Node

signal turn_started(combatant: Node)
signal turn_ended(combatant: Node)
signal round_ended

var combatants: Array[Node] = []
var turn_order: Array[Node] = []
var current_turn_index: int = 0

func start_combat(participants: Array[Node]) -> void:
    combatants = participants
    calculate_turn_order()
    start_next_turn()

func calculate_turn_order() -> void:
    turn_order = combatants.duplicate()
    turn_order.sort_custom(func(a, b): return a.speed > b.speed)

func start_next_turn() -> void:
    if current_turn_index >= turn_order.size():
        current_turn_index = 0
        round_ended.emit()
        calculate_turn_order()  # Recalculate each round
    
    var current := turn_order[current_turn_index]
    turn_started.emit(current)

func end_turn() -> void:
    var current := turn_order[current_turn_index]
    turn_ended.emit(current)
    current_turn_index += 1
    start_next_turn()
```

## Action Point System

```gdscript
# combatant.gd
extends Node

@export var max_action_points: int = 3
var current_action_points: int = 3

func start_turn() -> void:
    current_action_points = max_action_points

func can_perform_action(cost: int) -> bool:
    return current_action_points >= cost

func perform_action(cost: int) -> bool:
    if not can_perform_action(cost):
        return false
    
    current_action_points -= cost
    return true
```

## Turn Phases

```gdscript
enum Phase { DRAW, MAIN, END }

var current_phase: Phase = Phase.DRAW

func advance_phase() -> void:
    match current_phase:
        Phase.DRAW:
            current_phase = Phase.MAIN
        Phase.MAIN:
            current_phase = Phase.END
        Phase.END:
            TurnManager.end_turn()
            current_phase = Phase.DRAW
```

## Best Practices

1. **Speed-Based** - Initiative determines order
2. **Action Points** - Limit actions per turn
3. **Timeout** - Add turn timer for online play

## Reference
- Related: `godot-combat-system`, `godot-rpg-stats`


### Related
- Master Skill: [godot-master](../SKILL.md)
