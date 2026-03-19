---
name: godot-genre-moba
description: "Expert blueprint for MOBA games including lane logic (minion wave spawning every 30s), tower aggro priority (hero attacking ally over minion over hero), click-to-move controls (RTS-style raycasting), hero ability systems (QWER cooldowns, mana cost), fog of war (SubViewport projections), and authoritative networking (server validates damage). Use for competitive 5v5 or arena games. Trigger keywords: MOBA, lane_manager, minion_waves, tower_aggro, click_to_move, ability_cooldowns, fog_of_war, comeback_mechanics."
---

# Genre: MOBA (Multiplayer Online Battle Arena)

Expert blueprint for MOBAs emphasizing competitive balance and strategic depth.

## NEVER Do (Expert Anti-Patterns)

### Networking & Authority
- NEVER trust the client for damage calculation or resource costs; strictly validate mana, ranges, and hit detection on the **authoritative server** using `multiplayer.is_server()`.
- NEVER use `TRANSFER_MODE_RELIABLE` for continuous movement; strictly use `UNRELIABLE` or `UNRELIABLE_ORDERED` for position/velocity to prevent network congestion.
- NEVER sync units at 60Hz; strictly use a lower tick rate (10-20Hz) via `MultiplayerSynchronizer` and implement **Interp/Client-Side Prediction** for visual smoothness.
- NEVER attach individual synchronizers to hundreds of minions; strictly batch state updates into compressed byte arrays via a central manager.
- NEVER synchronize complex Engine objects directly; strictly serialize state into primitive properties or Dictionaries for reliable peer-to-peer sync.

### AI & Pathfinding
- NEVER use expensive pathfinding for all minions every frame; strictly use **Time Slicing** to spread `get_next_path_position()` calls across multiple frames.
- NEVER query `NavigationAgent` paths inside `_process()`; strictly use `_physics_process()` to interact with the navigation server and avoidance systems.
- NEVER use complex visual geometry for NavMesh baking; parse simple primitives to avoid stalling the `RenderingServer` or crashing the engine.
- NEVER set `path_search_max_polygons` too low in large maps; agents will stop or walk incorrectly if the limit is reached before the destination.
- NEVER use `Area2D` for high-performance Fog of War LOS; strictly use nodeless physics queries (`intersect_ray`) to bypass node overhead.

### Gameplay & Balancing
- NEVER forget Tower "Dive" protection; towers MUST switch targets immediately if an enemy Hero damages an allied Hero within range (Priority: Hero attacking Ally > Minion > Hero).
- NEVER allow "Snowballing" without counter-play; strictly implement **Comeback Mechanisms** (Kill Bounties, Catch-up XP) to maintain competitive tension.
- NEVER manage hero stats as standard Node variables; strictly use custom `Resource` scripts for data separation and memory efficiency.
- NEVER forget to call `duplicate(true)` on shared ability Resources; modifying a buff on a shared resource will affect all heroes globally.

### Technical & Performance
- NEVER use standard strings for status checks (e.g., "stunned"); strictly use `StringName` (&"stunned") for pointer-speed comparisons.
- NEVER loop over massive Fog of War grids with floats; strictly use `Vector2i` and `TileMapLayer` to prevent precision jitter.
- NEVER execute heavy world/minimap logic on the main thread; strictly offload complex array math to `WorkerThreadPool` to maintain 60+ FPS.
- NEVER rigidly couple UI cooldowns to Hero scripts; strictly use a Signal Bus or `Callable` bindings for decoupled architecture.
- NEVER evaluate exact floating-point equality (==); strictly use `is_equal_approx()` for range, cooldown, and mana validations.

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [skill_shot_indicator.gd](../scripts/genre_moba_skill_shot_indicator.gd) - Mouse-driven targeting system for range, width, and direction visualization.
- [tower_priority_aggro.gd](../scripts/genre_moba_tower_priority_aggro.gd) - Advanced AI for defensive towers following competitive priority rules.

### Modular Components
- [server_minion_sync.gd](../scripts/genre_moba_server_minion_sync.gd) - Authoritative sync for high-count units using compressed byte arrays.
- [fog_visibility_check.gd](../scripts/genre_moba_fog_visibility_check.gd) - Physics raycasting for high-performance Line-of-Sight checks.
- [fog_grid_mask.gd](../scripts/genre_moba_fog_grid_mask.gd) - TileMap-driven visibility masking system using Vector2i grid logic.
- [status_effect_data.gd](../scripts/genre_moba_status_effect_data.gd) - Lightweight Resource container forDefining buffs, debuffs, and stuns.
- [status_effect_manager.gd](../scripts/genre_moba_status_effect_manager.gd) - Modular logic for applying and managing unique status effect instances.
- [decoupled_ability_damage.gd](../scripts/genre_moba_decoupled_ability_damage.gd) - Inter-hero combat interaction using safe duck-typing patterns.
- [hero_state_machine.gd](../scripts/genre_moba_hero_state_machine.gd) - Optimized StringName-based state machine for hero logic.
- [async_arena_baker.gd](../scripts/genre_moba_async_arena_baker.gd) - Background thread-safe navigation mesh updates for dynamic arenas.
- [ability_ui_binder.gd](../scripts/genre_moba_ability_ui_binder.gd) - Signal-based UI decoupling for ability cooldown tracking.
- [minion_flow_calculator.gd](../scripts/genre_moba_minion_flow_calculator.gd) - Parallelized pathing and intelligence using WorkerThreadPool.

---

## Core Loop
1.  **Lane**: Player farms minions for gold/XP in a designated lane.
2.  **Trade**: Player exchanges damage with opponent hero.
3.  **Gank**: Player roams to other lanes to surprise enemies.
4.  **Push**: Team destroys towers to open the map.
5.  **End**: Destroy the enemy Core/Nexus.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Control | `rts-controls` | Right-click to move, A-move, Stop |
| 2. AI | `godot-navigation-pathfinding` | Minion waves, Tower aggro logic |
| 3. Combat | `godot-ability-system`, `godot-rpg-stats` | QWER abilities, cooldowns, scaling |
| 4. Network | `godot-multiplayer-networking` | Authority, lag compensation, prediction |
| 5. Map | `godot-3d-world-building` | Lanes, Jungle, River, Bases |

## Architecture Overview

### 1. Lane Manager
Spawns waves of minions periodically.

```gdscript
# lane_manager.gd
extends Node

@export var lane_path: Path3D
@export var spawn_interval: float = 30.0
var timer: float = 0.0

func _process(delta: float) -> void:
    timer -= delta
    if timer <= 0:
        spawn_wave()
        timer = spawn_interval

func spawn_wave() -> void:
    # Spawn 3 Melee, 3 Ranged, 1 Cannon (every 3rd wave)
    for i in range(3):
        spawn_minion(MeleeMinion, lane_path)
        await get_tree().create_timer(1.0).timeout
```

### 2. Minion AI
Simple but follows strict rules.

```gdscript
# minion_ai.gd
extends CharacterBody3D

enum State { MARCH, COMBAT }
var current_target: Node3D

func _physics_process(delta: float) -> void:
    match state:
        State.MARCH:
            move_along_path()
            scan_for_enemies()
        State.COMBAT:
            if is_instance_valid(current_target):
                attack(current_target)
            else:
                state = State.MARCH
```

### 3. Tower Aggro Logic
The most misunderstood mechanic by new players.

```gdscript
# tower.gd
func _on_aggro_check() -> void:
    # Priority 1: Enemy Hero attacking Ally Hero
    # Priority 2: Enemy Unit attacking Ally Hero
    # Priority 3: Closest Enemy Minion
    # Priority 4: Closest Enemy Hero
    var target = determine_best_target()
    if target:
        shoot_at(target)
```

### 4. Skill-Shot Ability Cycle
Implementation pattern for "QWER" targeting:
1. **Idle**: Waiting for input.
2. **Telegraphed**: Show indicator (`skill_shot_indicator.gd`) while mouse is held.
3. **Active**: Spawn hitbox/projectile on release.
4. **Recovery**: Brief backswing animation where movement/casting is locked.

## Key Mechanics Implementation

### Click-to-Move (RTS Style)
Raycasting from camera to terrain.

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("move"):
        var result = raycast_from_mouse()
        if result:
            nav_agent.target_position = result.position
```

### Ability System (Data Driven)
Defining "Fireball" or "Hook" without unique scripts for everything.

```gdscript
# ability_data.gd
class_name Ability extends Resource
@export var cooldown: float
@export var mana_cost: float
@export var damage: float
@export var effect_scene: PackedScene
```

## Godot-Specific Tips

*   **NavigationAgent3D**: Use `avoidance_enabled` for minions so they flow around each other like water, rather than stacking.
*   **MultiplayerSynchronizer**: Sync Health, Mana, and Cooldowns. Do NOT sync position every frame if using Client-Side Prediction (advanced).
*   **Fog of War**: Use a `SubViewport` with a fog texture. Paint "holes" in the texture where allies are. Project this texture onto the terrain shader.

## Common Pitfalls

1.  **Snowballing**: Winning team gets too strong too fast. **Fix**: Implement "Comeback XP/Gold" mechanisms (bounties).
2.  **Pathfinding Lag**: 100 minions pathing every frame. **Fix**: Distribute pathfinding updates over multiple frames (Time Slicing).
3.  **Hacking**: Client says "I dealt 1000 damage". **Fix**: Client says "I cast Spell Q at Direction V". Server calculates damage.


## Reference
- Master Skill: [godot-master](../SKILL.md)
