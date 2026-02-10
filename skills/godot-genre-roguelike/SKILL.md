---
name: godot-genre-roguelike
description: "Expert blueprint for roguelikes including procedural generation (Walker method, BSP rooms), permadeath with meta-progression (unlock persistence), run state vs meta state separation, seeded RNG (shareable runs), loot/relic systems (hook-based modifiers), and difficulty scaling (floor-based progression). Use for dungeon crawlers, action roguelikes, or roguelites. Trigger keywords: roguelike, procedural_generation, permadeath, meta_progression, seeded_RNG, relic_system, run_state."
---

# Genre: Roguelike

Expert blueprint for roguelikes balancing challenge, progression, and replayability.

## NEVER Do

- **NEVER make runs pure RNG** — Skill should mitigate bad luck. Provide  guaranteed item shops, reroll mechanics, or starting loadout choices.
- **NEVER overpowered meta-upgrades** — If meta-progression is too strong, game becomes "grind to win" not "learn to win". Keep modest (+10% damage max).
- **NEVER lack variety in content** — Procedural generation shuffles content. Need 50+ rooms, 20+ enemies, 100+ items minimum for freshness.
- **NEVER use unseeded RNG** — Always initialize RandomNumberGenerator with seed. Enables shareable/reproducible runs.
- **NEVER allow save scumming** — Save state only on floor transition. Delete save on load (standard for strict roguelikes).
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [meta_progression_manager.gd](scripts/meta_progression_manager.gd)
Cross-run persistence for currency and upgrades. JSON save/load with upgrade purchase/level tracking. Encrypt for production builds.

---

## Core Loop
1.  **Preparation**: Select character, equip meta-upgrades.
2.  **The Run**: complete procedural levels, acquire temporary power-ups.
3.  **The Challenge**: Survive increasingly difficult encounters/bosses.
4.  **Death/Victory**: Run ends, resources calculated.
5.  **Meta-Progression**: Spend resources on permanent unlocks/upgrades.
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

### Procedural Dungeon Generation (Walker Method)
A simple "drunkard's walk" algorithm for organic, cave-like or connected room layouts.

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
