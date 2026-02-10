---
name: godot-turn-system
description: "Expert blueprint for turn-based combat with turn order, action points, phase management, and timeline systems for strategy/RPG games. Covers speed-based initiative, interrupts, and simultaneous turns. Use when implementing turn-based combat OR tactical systems. Keywords turn-based, initiative, action points, phase, round, turn order, combat."
---

# Turn System

Turn order calculation, action points, phase management, and timeline systems define turn-based combat.

## Available Scripts

### [active_time_battle.gd](scripts/active_time_battle.gd)
Framework for Active Time Battle (ATB) systems with async action support.

### [timeline_turn_manager.gd](scripts/timeline_turn_manager.gd)
Expert timeline-based turn manager with interrupts and simultaneous actions.

## NEVER Do in Turn Systems

- **NEVER recalculate turn order every action** — Sort 50 combatants after every move? O(n log n) × actions = lag. Calculate once per round, update on stat changes only.
- **NEVER use speed ties without determinism** — Two units same speed, random order? Non-reproducible replays. Break ties with secondary stat (ID, position, etc.).
- **NEVER forget to validate action costs** — Allow action without checking points? Negative AP = exploits. ALWAYS `if can_perform_action(cost)` before deducting.
- **NEVER hardcode phase transitions** — `if phase == 0: phase = 1` for 10 phases? Unmaintainable. Use enum + match OR array of phase handlers.
- **NEVER skip turn timeout for networked games** — Wait forever for player input? Griefing exploit. ALWAYS implement turn timer with default action.
- **NEVER emit turn_ended before cleanup** — Signal listeners start next turn, previous hasn't cleaned up? State corruption. Cleanup FIRST, then emit.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)
