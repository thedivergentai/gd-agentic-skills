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

## NEVER Do (Expert Anti-Patterns)

### Design & Strategy
- NEVER make all towers have the same niche; strictly ensure distinct specialties: **Aura Slow**, **Armor Piercing**, **Anti-Air**, **Burst Sniper**, and **Splash Damage**.
- NEVER allow a "Death Spiral" with no exit; strictly provide small **comeback bonuses** or interest on saved gold to prevent early inevitable failure.
- NEVER make early waves feel like busywork; strictly provide an **"Early Call" bonus** to skip wait times and accelerate engagement.
- NEVER trust client-side economy updates; strictly require the **authoritative server** to validate currency addition and tower purchases in co-op.

### Pathing & Placement
- NEVER allow the player to "Seal" the exit in mazing games; strictly validate path existence with **`NavigationServer2D.map_get_path()`** before finalizing tower placement.
- NEVER use synchronous `bake_navigation_polygon()` for mazing; strictly offload to a **worker thread** to prevent 100ms+ frame hitches during placement.
- NEVER use global coordinates for grid logic; strictly convert to **Vector2i/Vector3i** to ensure pixel-perfect tower alignment.

### Performance & Systems
- NEVER call `get_overlapping_bodies()` every frame; strictly use **signals** (`body_entered`/`body_exited`) to maintain a local target cache.
- NEVER use `_process()` for projectile movement if count > 500; strictly use the **PhysicsServer2D/3D** directly for high-performance bullet-hell tiers.
- NEVER spawn hundreds of projectiles as full Nodes; strictly use **Object Pooling** to reuse resources and avoid garbage collection stutters.
- NEVER use standard Strings for priorities; strictly use `StringName` (&"first", &"strongest") for O(1) hash comparisons in targeting loops.
- NEVER ignore the `progress` property on PathFollow nodes; strictly use it as the O(1) way to identify the **target closest to exit**.
- NEVER process tower search logic every frame; strictly **throttle ACQUIRE searches** (e.g., every 5-10 frames) to save significant CPU cycles.
- NEVER scale Tower `CollisionShape` non-uniformly; strictly adjust the radius property of the Shape resource to preserve collision math.
- NEVER delete enemies immediately on death; strictly use **set_deferred("disabled", true)** and wait one frame to prevent physics server crashes.
- NEVER hardcode waves in huge switch statements; strictly use **Custom Resources (.tres)** for clean balancing and sequence editing.

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [wave_manager.gd](../scripts/genre_tower_defense_wave_manager.gd) - Professional wave orchestrator with Resource-based enemy composition and cleanup.
- [tower.gd](../scripts/genre_tower_defense_tower.gd) - Base turret class with FSM state management and firing logic.
- [tower_targeting_system.gd](../scripts/genre_tower_defense_tower_targeting_system.gd) - Autonomous priority logic (First/Last/Strongest/Weakest) for efficient targeting.

### Modular Components
- [tower_defense_patterns.gd](../scripts/genre_tower_defense_tower_defense_patterns.gd) - Collection of patterns for furthest-target logic and PhysicsServer projectile optimization.

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
- Master Skill: [godot-master](../SKILL.md)
