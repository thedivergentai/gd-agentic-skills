> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Tower Defense**. Accessed via Godot Master.

# Genre: Tower Defense

Expert blueprint for building Tower Defense (TD) games. Covers wave management, sophisticated autonomous turret targeting (First/Last/Strongest), and pathfinding variants (Fixed Path vs. Mazing).

## Available Scripts

### [wave_manager.gd](../scripts/godot-genre-tower-defense_wave_manager.gd)
A professional wave orchestrator. Handles timers between waves, enemy composition definitions (using Resources), and clean cleanup signals for wave completion.

### [tower.gd](../scripts/godot-genre-tower-defense_tower.gd)
The base class for defensive structures. Implements a Finite State Machine (IDLE, ACQUIRE, ATTACK, COOLDOWN) and handles turret rotation and projectile firing logic.

### [tower_targeting_system.gd](../scripts/godot-genre-tower-defense_tower_targeting_system.gd)
Advanced logic for turret autonomous priority. Allows players to switch between targeting modes: **First** (closest to exit), **Last**, **Strongest** (max health), **Weakest**, or **Closest** (geometric distance).


## NEVER Do

- **NEVER use synchronous `bake_navigation_polygon()` in mazing games** — Re-baking navigation on the main thread during a large building placement will cause the game to "hitch" or freeze for 100ms+. Always perform bake operations on a background thread OR use fixed path nodes.
- **NEVER allow the player to "Seal" the exit** — In games where players build the path (Mazing), you MUST validate every build. Use `NavigationServer2D.map_get_path()` before a tower is finalized; if the path is empty, reject the placement and show an "Illegal Move" error.
- **NEVER call `get_overlapping_bodies()` every frame** — If you have 20 towers and 500 enemies, this results in 10,000 expensive physics calls per frame. Instead, use signals (`body_entered` / `body_exited`) to maintain a local `targets_in_range` Array.
- **NEVER make all towers have the same niche** — If every tower is just "deal damage," there is no strategy. Distinct niches are mandatory: **Aura Slow**, **Armor Piercing**, **Anti-Air**, **Burst Sniper**, and **Splash Damage**.
- **NEVER allow a "Death Spiral" with no exit** — If leaking one enemy causes a permanent loss of income that prevents future defense, the player is doomed 20 waves before they actually lose. Provide small "comeback" bonuses or interest on saved gold.
- **NEVER use `_process()` for projectile movement if count is > 500** — For bullet-hell style TD waves, use the `PhysicsServer2D` directly for projectile movement to avoid the overhead of thousands of individual Node scripts.

---

## Pathfinding Variants
1. **Fixed Path (Path2D)**:
   - Enemies follow a curve.
   - **Targeting "First"**: Simple. Monitor `progress_ratio` on the `PathFollow2D`.
2. **Mazing (NavigationAgent)**:
   - Towers act as obstacles.
   - **Baking**: Use `NavigationServer2D` to bake navigation meshes dynamically when towers are placed or destroyed.

## Target Selection Logic
A tower should pick its victim based on a priority strategy:
- **STRONGEST**: `targets_in_range.sort_custom(func(a, b): return a.health > b.health)`
- **FIRST (Path-based)**: `targets_in_range.sort_custom(func(a, b): return a.progress > b.progress)`
- **CLOSEST**: `targets_in_range.sort_custom(func(a, b): return a.dist_to_tower < b.dist_to_tower)`

## Wave Orchestration
Design waves using `Resource` files (.tres):
- `delay_before_wave`: float
- `enemy_groups: Array[EnemyGroup]`
  - `scene`: PackedScene
  - `count`: int
  - `interval`: float

## Projectile Prediction Math
To hit a moving enemy with a slow projectile:
```gdscript
var time_to_hit = distance / projectile_speed
var predicted_pos = target.position + (target.velocity * time_to_hit)
turret.look_at(predicted_pos)
```

## Performance: Object Pooling
Do NOT `instantiate()` and `queue_free()` 500 bullets per second.
- Create a pool of 1,000 bullets at game start.
- "Spawn" by making them visible and enabling physics.
- "Despawn" by hiding them and resetting their state.

## Reference
- [Godot Docs: Path-following with Path2D](https://docs.godotengine.org/en/stable/classes/class_pathfollow2d.html)
- [GDC: The Math of Tower Defense](https://www.youtube.com/watch?v=N_pE0O6X5F0)
