---
name: godot-genre-tower-defense
description: "Expert blueprint for tower defense games (Bloons TD, Kingdom Rush, Fieldrunners) covering wave management, tower targeting logic, path algorithms, economy balance, and mazing mechanics. Use when building TD, lane defense, or tower placement strategy games. Keywords tower defense, wave spawner, pathfinding, targeting priority, mazing, NavigationServer baking."
---

# Genre: Tower Defense

Strategic placement, resource management, and escalating difficulty define tower defense.

## Core Loop
1.  **Prepare**: Build/upgrade towers with available currency
2.  **Wave**: Enemies spawn and traverse path toward goal
3.  **Defend**: Towers auto-target and damage enemies
4.  **Reward**: Kills grant currency
5.  **Escalate**: Waves increase in difficulty/complexity

## NEVER Do in Tower Defense Games

- **NEVER make all towers equally viable** — If Sniper = same DPS as Machine Gun, no strategic choice. Each tower MUST have distinct niche (AoE, slow, armor pierce, anti-air).
- **NEVER use synchronous NavigationServer baking for mazing** — `NavigationRegion2D.bake_navigation_polygon()` blocks main thread. Use `NavigationServer2D.get_maps()` + worker thread OR fixed paths.
- **NEVER let players fully block the exit path** — In mazing TDs, validate `NavigationServer2D.map_get_path(start, goal)` before tower placement. Empty path = illegal build.
- **NEVER use `Area2D.get_overlapping_bodies()` every frame** — 500 enemies × 60fps = 30k collision checks. Store `bodies_entered` in array, remove on `body_exited`. Query once.
- **NEVER make early waves feel like busywork** — First 3 waves should introduce mechanics, not bore. Start timer at 50% or give "early call" bonus to skip.
- **NEVER allow death spirals without catch-up mechanics** — 1 leaked enemy → less money → harder next wave → inevitable loss. Add interest on saved money OR discrete wave difficulty.

---

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Grid/Path | `godot-tilemap-mastery`, `navigation-2d` | Defining where enemies walk and towers build |
| 2. Towers | `math-geometry`, `area-2d` | Range checks, rotation, projectile prediction |
| 3. Enemies | `path-following`, `steering-behaviors` | Movement along paths |
| 4. Management | `state-machines`, `loop-management` | Wave spawning logic, game phases |
| 5. UI | `ui-system`, `drag-and-drop` | Building towers, inspecting stats |

## Architecture Overview

### 1. Wave Manager
Handles the timing and godot-composition of enemy waves.

```gdscript
# wave_manager.gd
extends Node

signal wave_started(wave_index: int)
signal wave_cleared
signal enemy_spawned(enemy: Node2D)

@export var waves: Array[Resource] # Array of WaveDefinition resources
var current_wave_index: int = 0
var active_enemies: int = 0

func start_next_wave() -> void:
    if current_wave_index >= waves.size():
        print("All waves cleared!")
        return
        
    var wave_data = waves[current_wave_index]
    wave_started.emit(current_wave_index)
    _spawn_wave(wave_data)
    current_wave_index += 1

func _spawn_wave(wave: WaveResource) -> void:
    for group in wave.groups:
        await get_tree().create_timer(group.delay).timeout
        for i in group.count:
            var enemy = group.enemy_scene.instantiate()
            add_child(enemy)
            active_enemies += 1
            enemy.tree_exiting.connect(_on_enemy_died)
            await get_tree().create_timer(group.interval).timeout

func _on_enemy_died() -> void:
    active_enemies -= 1
    if active_enemies <= 0:
        wave_cleared.emit()
```

### 2. Tower Logic (State Machine)
Towers act as autonomous agents.

*   **States**: `Idle`, `AcquireTarget`, `Attack`, `Cooldown`.
*   **Targeting Priority**: `First`, `Last`, `Strongest`, `Weakest`, `Closest`.

```gdscript
# tower.gd
extends Node2D

var targets_in_range: Array[Node2D] = []
var current_target: Node2D

func _physics_process(delta: float) -> void:
    if current_target == null or not is_instance_valid(current_target):
        _acquire_target()
    
    if current_target:
        _rotate_turret(current_target.global_position)
        if can_fire():
            fire_projectile()

func _acquire_target() -> void:
    # Example: Target closest to end of path
    var max_progress = -1.0
    for enemy in targets_in_range:
        if enemy.progress > max_progress:
            current_target = enemy
            max_progress = enemy.progress
```

### 3. Pathfinding Variants

#### A. Fixed Path (Kingdom Rush style)
Enemies follow a pre-defined `Path2D`.
*   **Implementation**: `PathFollow2D` as parent of Enemy.
*   **Pros**: Deterministic, easy to balance, optimized.
*   **Cons**: Less player agency in shaping the path.

#### B. Mazing (Fieldrunners style)
Players build towers to block/reroute enemies.
*   **Implementation**: `NavigationAgent2D` on enemies. Towers update `NavigationRegion2D` (bake on separate thread).
*   **Pros**: High strategic depth.
*   **Cons**: Computationally expensive recalculation, needs anti-blocking logic (don't let player seal the exit).

## Key Mechanics Implementation

### Targeting Math (Projectile Prediction)
To hit a moving target, you must predict where it will be.

```gdscript
func get_predicted_position(target: Node2D, projectile_speed: float) -> Vector2:
    var to_target = target.global_position - global_position
    var time_to_hit = to_target.length() / projectile_speed
    return target.global_position + (target.velocity * time_to_hit)
```

### Economy
Money management is the secondary core loop.
*   **Kill Rewards**: Direct feedback for success.
*   **Interest/Income**: Rewarding saved money (risk/reward).
*   **Early Calling**: Bonus money for starting the next wave early.

## Common Pitfalls

1.  **Death Spirals**: If a player leaks one enemy, they lose money/lives, making the next wave harder, leading to inevitable failure. **Fix**: Catch-up mechanics or discrete wave difficulty.
2.  **Useless Towers**: Every tower type must have a distinct niche (AoE, Slow, Armor Pierce, Anti-Air).
3.  **Path Blocking**: In mazing games, ensure players cannot completely block the path to the exit. Use `NavigationServer2D.map_get_path` to validate placement before building.

## Godot-Specific Tips

*   **Physics Layers**: Put enemies on a specific layer (e.g., Layer 2) and tower "range" Areas on a different mask to avoid towers detecting each other or walls.
*   **Area2D Performance**: For massive numbers of enemies, avoid `monitorable/monitoring` on every frame if possible. Use `PhysicsServer2D` queries for optimization if enemy count > 500.
*   **Object Pooling**: Essential for projectiles and enemies to avoid garbage collection stutters during intense waves.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
