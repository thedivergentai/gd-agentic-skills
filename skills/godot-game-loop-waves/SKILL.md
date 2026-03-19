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

## NEVER Do

- **NEVER iterate through get_children() to find all enemies** — This is extremely slow. Always add enemies to an "enemies" group and use `get_tree().get_nodes_in_group(&"enemies")` for efficient access.
- **NEVER constantly instantiate() and queue_free() hundreds of enemies** — This causes garbage collection stutters. Use an object pool to reuse existing enemy instances.
- **NEVER spawn thousands of separate MeshInstance3D nodes for swarms** — This will tank your draw calls. Use `MultiMeshInstance3D` to batch thousands of meshes into a single GPU call.
- **NEVER calculate pathfinding for hundreds of agents on the main thread** — This will freeze your game. Enable `use_async_iterations` on your navigation regions or use `NavigationServer3D.query_path()`.
- **NEVER forget to check is_inside_tree() before adding a child** — If the spawner is queued for deletion, adding a child will crash. Always verify the spawner is still active in the tree.
- **NEVER assign a preloaded resource (like stats.tres) directly to spawned mobs** — They will all share the exact same health/stats. Always call `base_stats.duplicate_deep()` to give each mob its own unique data.
- **NEVER use standard strings for high-frequency group calls** — Always use `StringName` (&"enemies", &"take_damage") for optimal hash performance and to avoid unnecessary string allocations.
- **NEVER spawn entities directly inside physics callbacks synchronously** — Instantiating nodes during physics steps can corrupt the physics state. Always use `call_deferred(&"add_child", enemy)`.
- **NEVER leave CollisionShapes on dead enemies active** — Corpses will block towers and navigation. Use `set_deferred("disabled", true)` immediately upon death.
- **NEVER synchronize complex Object types via MultiplayerSynchronizer** — It only supports primitive types. For complex data, sync a UID or ID and look up the data locally on the client.
- **NEVER auto-start waves without player feedback** — Always provide a UI countdown, a visual "Wave Incoming" effect, or a start button to maintain player agency.
- **NEVER hardcode spawn positions at (0,0,0)** — Use `Marker3D` nodes in the editor so you can visually adjust spawn points without digging into code.
- **NEVER check wave completion by counting children every frame** — It's too expensive. Maintain a local counter or use a signal-based system to track active enemy counts.
- **NEVER use the same navigation map for every entity type** — If you have flying and walking enemies, use separate navigation maps to prevent pathing issues.
- **NEVER scale collision shapes non-uniformly for spawners** — This breaks the collision detection math. Adjust the shape resource properties instead.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [wave_loop_patterns.gd](scripts/wave_loop_patterns.gd)
10 Expert patterns: MultiMesh swarms, async pathfinding, background preloading, and server-side physics mobs.

### [wave_manager.gd](scripts/wave_manager.gd)
Orchestrates the timeline, delays between waves, and tracks "Victory" conditions.

### [wave_resource.gd](scripts/wave_resource.gd)
Data containers for wave compositions and difficulty settings.
