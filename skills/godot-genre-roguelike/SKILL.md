---
name: godot-genre-roguelike
description: "Expert blueprint for roguelikes including procedural generation (Walker method, BSP rooms), permadeath with meta-progression (unlock persistence), run state vs meta state separation, seeded RNG (shareable runs), loot/relic systems (hook-based modifiers), and difficulty scaling (floor-based progression). Use for dungeon crawlers, action roguelikes, or roguelites. Trigger keywords: roguelike, procedural_generation, permadeath, meta_progression, seeded_RNG, relic_system, run_state."
---

# Genre: Roguelike

Expert blueprint for roguelikes balancing challenge, progression, and replayability.

## NEVER Do (Expert Anti-Patterns)

### Generation & RNG
- NEVER make runs dependent on pure RNG; strictly provide **mitigation** (rerolls, shops, pity timers) to ensure every run is winnable.
- NEVER use unseeded RNG for world generation; strictly initialize isolated `RandomNumberGenerator` with a predictable seed for daily runs/debugging.
- NEVER rely on `@GlobalScope.randi()` for critical logic; strictly use local RNG instances to prevent global state pollution.
- NEVER use `Array.pick_random()` for critical content drops; strictly use a **Shuffle Bag** to prevent statistically unfair streaks.
- NEVER generate massive dungeons on the main thread; strictly use **`WorkerThreadPool.add_task()`** or **`add_group_task()`** to distribute generation across cores and prevent frame freezes.
- NEVER interact with the SceneTree from a background thread; strictly generate dungeon data in a **thread-safe Array/PackedByteArray** before parsing on the main thread.

### Data & State
- NEVER allow **Save Scumming**; strictly delete mid-run save files immediately upon loading to enforce permadeath.
- NEVER allow Run State to leak into Meta State; strictly use separate singletons or Resources for `RunManager` and `MetaManager`.
- NEVER scale meta-progression to be overpowered (+100% damage); strictly keep upgrades subtle (+5-15%) to maintain skill-based play.
- NEVER forget to call `duplicate(true)` on base stat Resources; failing to deep-duplicate causes all entities to share a single health instance.
- NEVER save run states to `.tscn` files; strictly serialize to JSON or binary in `user://` to prevent bloat.
- NEVER rely on the `SceneTree` as the source of truth for grid logic; strictly maintain grid data in a separate Dictionary or Array.

### Grid & Performance
- NEVER forget to handle **Navigation re-baking**; strictly rebake `NavigationRegion2D` AFTER procedural tiles are placed.
- NEVER use AStar2D for tile grids; strictly use **`AStarGrid2D`** with **`jumping_enabled = true`** (Jump Point Search) for O(1) queries and high-performance pathing across open areas.
- NEVER forget to call `update()` on `AStarGrid2D` after modifying states; strictly ensures pathfinding queries aren't stale.
- NEVER use floats (`Vector2`) for discrete grid coordinates; strictly use **Vector2i** to prevent precision drift.
- NEVER use Manhattan heuristics for 8-way movement; strictly use **`HEURISTIC_CHEBYSHEV`** or **`HEURISTIC_OCTILE`**.
- NEVER iterate over every cell coordinate (0 to W,H) in GDScript; strictly use `get_used_cells()` for optimized tile access.
- NEVER clear procedural levels using `free()`; strictly use `queue_free()` to avoid mid-frame segmentation faults.
- NEVER broadcast mass state changes to a grid immediately; strictly use `call_deferred()` or **`call_group_flags`** to avoid frame spikes during turn transitions.
- NEVER use heavy TileMapLayer nodes for high-resolution Fog of War; strictly use a **GPU Shader Mask** via `ColorRect` and an `ImageTexture` updated via **`RenderingServer.texture_2d_update()`**.

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [meta_progression_manager.gd](scripts/meta_progression_manager.gd) - Foundational meta-progression logic with secure data persistence and currency unlocks.
- [roguelike_patterns.gd](scripts/roguelike_patterns.gd) - 10 Essential Roguelike Expert Snippets (AStar, BSP, WorkerThreadPool, ShuffleBag, etc.).

### Modular Components
- [dungeon_generator_walker.gd](scripts/dungeon_generator_walker.gd) - Drunkard's Walk algorithm for carving procedural rooms and caves.
- [fov_raycast_calculator.gd](scripts/fov_raycast_calculator.gd) - High-performance LOS checking using physics server queries.
- [seeded_rng_resource.gd](scripts/seeded_rng_resource.gd) - RNG state persistence for deterministic and shareable replayability.
- [turn_manager_decoupled.gd](scripts/turn_manager_decoupled.gd) - Signal-driven turn coordination for decoupled entity logic.
- [astar_grid_handler.gd](scripts/astar_grid_handler.gd) - Specialised AStarGrid2D wrapper for optimized roguelike pathfinding.
- [weighted_loot_table.gd](scripts/weighted_loot_table.gd) - Native-optimized weighted random item drops with drop-rate controls.
- [json_state_serializer.gd](scripts/json_state_serializer.gd) - Persistent serialization for procedural entity data and run states.
- [fog_of_war_masker.gd](scripts/fog_of_war_masker.gd) - TileMapLayer-based visibility masking and discovery system.
- [meta_progression_resource.gd](scripts/meta_progression_resource.gd) - Data separation for permanent game unlocks and skill trees.
- [move_command_object.gd](scripts/move_command_object.gd) - Command pattern implementation for reversible turn-based actions.
- [dungeon_generator.gd](scripts/dungeon_generator.gd) - High-level procedural orchestrator for room-and-hallway layout generation.

## Core Loop
1.  **Preparation**: Select character, equip meta-upgrades (see `meta_progression_resource.gd`).
2.  **The Run**: complete procedural levels (`dungeon_generator_walker.gd`), acquire temporary power-ups.
3.  **The Challenge**: Survive increasingly difficult encounters using A* pathfinding (`astar_grid_handler.gd`).
4.  **Death/Victory**: Run ends, resources calculated.
5.  **Meta-Progression**: Spend resources on permanent unlocks (`meta_progression_resource.gd`).
6.  **Repeat**: Start a new run with new capabilities.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Architecture | `state-machines`, `autoloads` | Managing Run State vs Meta State |
| 2. World Gen | `godot-procedural-generation`, `tilemap`, `noise` | Creating unique levels every run |
| 3. Combat | `godot-combat-system`, `enemy-ai` | Fast-paced, high-stakes encounters |
| 4. Progression | `loot-tables`, `godot-inventory-system` | Managing run-specific items/relics |
| 5. Persistence | `save-system`, `resources` | Saving meta-progress between runs |

## Architecture Overview

Roguelikes require a strict separation between **Run State** (temporary) and **Meta State** (persistent).

### 1. Run Manager (AutoLoad)
Handles the lifespan of a single run. Resets completely on death.

```gdscript
# run_manager.gd
extends Node

signal run_started
signal run_ended(victory: bool)
signal floor_changed(new_floor: int)

var current_seed: int
var current_floor: int = 1
var player_stats: Dictionary = {}
var inventory: Array[Resource] = []
var rng: RandomNumberGenerator

func start_run(seed_val: int = -1) -> void:
    rng = RandomNumberGenerator.new()
    if seed_val == -1:
        rng.randomize()
        current_seed = rng.seed
    else:
        current_seed = seed_val
        rng.seed = current_seed
        
    current_floor = 1
    _reset_run_state()
    run_started.emit()

func _reset_run_state() -> void:
    player_stats = { "hp": 100, "gold": 0 }
    inventory.clear()

func next_floor() -> void:
    current_floor += 1
    floor_changed.emit(current_floor)
    
func end_run(victory: bool) -> void:
    run_ended.emit(victory)
    # Trigger meta-progression save here
```

### 2. Meta-Progression (Resource)
Stores permanent unlocks.

```gdscript
# meta_progression.gd
class_name MetaProgression
extends Resource

@export var total_runs: int = 0
@export var unlocked_weapons: Array[String] = ["sword_basic"]
@export var currency: int = 0
@export var skill_tree_nodes: Dictionary = {} # node_id: level

func save() -> void:
    ResourceSaver.save(self, "user://meta_progression.tres")

static func load_or_create() -> MetaProgression:
    if ResourceLoader.exists("user://meta_progression.tres"):
        return ResourceLoader.load("user://meta_progression.tres")
    return MetaProgression.new()
```

## Key Mechanics implementation

### Procedural Dungeon Generation
- **Drunkard's Walk (Walker)**: Ideal for organic, cave-like or connected room layouts.
- **Binary Space Partitioning (BSP)**: Best for rectangular, connected room-and-hallway dungeons.
- **Wave Function Collapse (WFC)**: For highly detailed, rule-based tile environments and modular room assembly.

```gdscript
# dungeon_generator.gd
extends Node

@export var map_width: int = 50
@export var map_height: int = 50
@export var max_walkers: int = 5
@export var max_steps: int = 500

func generate_dungeon(tilemap: TileMapLayer, rng: RandomNumberGenerator) -> void:
    tilemap.clear()
    var walkers: Array[Vector2i] = [Vector2i(map_width/2, map_height/2)]
    var floor_tiles: Array[Vector2i] = []
    
    for step in max_steps:
        var new_walkers: Array[Vector2i] = []
        for walker in walkers:
            floor_tiles.append(walker)
            # 25% chance to destroy walker, 25% to spawn new one
            if rng.randf() < 0.25 and walkers.size() > 1:
                continue # Destroy
            if rng.randf() < 0.25 and walkers.size() < max_walkers:
                new_walkers.append(walker) # Spawn
            
            # Move walker
            var direction = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()
            new_walkers.append(walker + direction)
        
        walkers = new_walkers
    
    # Set tiles
    for pos in floor_tiles:
        tilemap.set_cell(pos, 0, Vector2i(0,0)) # Assuming source_id 0 is floor
    
    # Post-process: Add walls, spawn points, etc.
```

### Item/Relic System (Resource-based)
Relics modify stats or add behavior.

```gdscript
# relic.gd
class_name Relic
extends Resource

@export var id: String
@export var name: String
@export var icon: Texture2D
@export_multiline var description: String

# Hook system for complex interactions
func on_pickup(player: Node) -> void:
    pass

func on_damage_dealt(player: Node, target: Node, damage: int) -> int:
    return damage # Return modified damage

func on_kill(player: Node, target: Node) -> void:
    pass
```

```gdscript
# example_relic_vampirism.gd
extends Relic

func on_kill(player: Node, target: Node) -> void:
    player.heal(5)
    print("Vampirism triggered!")
```

## Common Pitfalls

1.  **RNG Dependency**: Don't make runs entirely dependent on luck. Good roguelikes allow skill to mitigate bad RNG.
2.  **Meta-progression Imbalance**: If meta-upgrades are too strong, the game becomes a "grind to win" rather than "learn to win".
3.  **Lack of Variety**: Procedural generation is only as good as the content it arranges. You need *a lot* of content (rooms, enemies, items) to keep it fresh.
4.  **Save Scumming**: Players will try to quit to avoid death. Save the state only on floor transition or quit, and delete the save on load (optional, but standard for strict roguelikes).

## Godot-Specific Tips

-   **Seeded Runs**: Always initialize `RandomNumberGenerator` with a seed. This allows players to share specific run layouts.
-   **ResourceSaver**: Use `ResourceSaver` for meta-progression, but be careful with cyclical references in deeply nested resources.
-   **Scenes as Rooms**: Build your "rooms" as separate scenes (`Room1.tscn`, `Room2.tscn`) and instance them into the generated layout for handcrafted quality within procedural layouts.
-   **Navigation**: Rebake `NavigationRegion2D` at runtime after generating the dungeon layout if using 2D navigation.

## Advanced Techniques

-   **Synergy System**: Tag items (`fire`, `projectile`, `companion`) and check for tag combinations to create emergent power-ups.
-   **Director AI**: An invisible "Director" system that tracks player health/stress and adjusts spawn rates dynamically (like *Left 4 Dead*).


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
