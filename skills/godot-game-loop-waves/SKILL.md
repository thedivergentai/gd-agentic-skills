---
name: godot-game-loop-waves
description: Expert patterns for managing combat waves, difficulty scaling, and automated enemy spawning in Godot 4. Use when building wave-based shooters, tower defense, or arena games.
---

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
# wave_manager.gd snippet
func start_next_wave():
    # Delay for juice/prep
    await get_tree().create_timer(pre_delay).timeout 
    wave_started.emit()
    _spawn_logic()
```

### 2. Composition-Based Spawning
Manage enemy variety using a Dictionary-based composition strategy in your `WaveResource`.

```gdscript
# wave_resource.gd
@export var compositions: Dictionary = {
    "Res://Enemies/Goblin.tscn": 10,
    "Res://Enemies/Orc.tscn": 2
}
```

## Master Decision Matrix: Progression

| Pattern | Best For | Logic |
| :--- | :--- | :--- |
| **Linear** | Story missions | Hand-crafted list of `WaveResource`. |
| **Endless** | Survival modes | Code-generated `WaveResource` with multiplier math. |
| **Triggered** | RPG Encounters | Wave starts only when player enters an `Area3D`. |

## Veteran-Only Gotchas (Never List)

- **NEVER use `get_nodes_in_group("enemies").size()`** to check wave status. It's too expensive. Maintain an `active_enemies` array in the Manager.
- **NEVER auto-start waves without feedback**. Always provide a UI countdown or a "Start Wave" button for player agency.
- **NEVER spawn at `(0,0,0)`**. Always anchor spawns to `Marker3D` or `Marker2D` nodes so you can move them in the editor.
- **Juice**: Use `wave_cleared` signals to play a "Safe" music track or trigger a shop phase.

## Registry

- **Expert Component**: [wave_manager.gd](scripts/wave_manager.gd)
- **Expert Component**: [wave_resource.gd](scripts/wave_resource.gd)
- **Expert Component**: [wave_spawner.gd](scripts/wave_spawner.gd)
