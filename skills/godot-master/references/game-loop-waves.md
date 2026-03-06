# Wave Loop: Combat Pacing

> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Wave Loops**. Accessed via Godot Master.

## Architectural Thinking: The "Wave-State" Pattern

A Master implementation treats waves as **Data-Driven Transitions**. Instead of hardcoding spawn counts, use a `WaveResource` to define "Encounters" that the `WaveManager` processes sequentially.

### Core Responsibilities
- **Manager**: Orchestrates the timeline. Handles delays between waves and tracks "Victory" conditions (all enemies dead).
- **Spawner**: Decoupled nodes that provide spatial context for where enemies appear.
- **Resource**: Immutable data containers that allow designers to rebalance the game without touching code.

## Expert Code Patterns

### 1. The Async Wave Trigger
Use `await` and timers to handle pacing without cluttering the `_process` loop.

```gdscript
# game_loop_waves_manager.gd snippet
func start_next_wave():
    await get_tree().create_timer(pre_delay).timeout 
    wave_started.emit()
    _spawn_logic()
```

### 2. Composition-Based Spawning
Manage enemy variety using a Dictionary-based composition strategy in your `WaveResource`.

```gdscript
# game_loop_waves_resource.gd
@export var compositions: Dictionary = {
    "res://enemies/goblin.tscn": 10,
    "res://enemies/orc.tscn": 2
}
```

## Master Decision Matrix: Progression

| Pattern | Best For | Logic |
| :--- | :--- | :--- |
| **Linear** | Story missions | Hand-crafted list of `WaveResource`. |
| **Endless** | Survival modes | Code-generated `WaveResource` with multiplier math. |
| **Triggered** | RPG Encounters | Wave starts only when player enters an `Area3D`. |

## NEVER Do
- **NEVER use `get_nodes_in_group("enemies").size()`** to check wave status. Maintain an `active_enemies` array.
- **NEVER auto-start waves without feedback**. Provide a UI countdown.
- **NEVER spawn at `(0,0,0)`**. Anchor spawns to `Marker` nodes.

## Registry
- **Expert Component**: [game_loop_waves_manager.gd](../scripts/game_loop_waves_manager.gd)
- **Expert Component**: [game_loop_waves_resource.gd](../scripts/game_loop_waves_resource.gd)
- **Expert Component**: [game_loop_waves_spawner.gd](../scripts/game_loop_waves_spawner.gd)
