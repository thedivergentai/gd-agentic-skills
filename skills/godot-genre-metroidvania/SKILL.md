---
name: godot-genre-metroidvania
description: "Expert blueprint for Metroidvanias including ability-gated exploration (locks/keys), interconnected world design (backtracking with shortcuts), persistent state tracking (collectibles, boss defeats), room transitions (seamless loading), map systems (grid-based revelation), and ability versatility (combat + traversal). Use for exploration platformers or action-adventure games. Trigger keywords: metroidvania, ability_gating, interconnected_world, backtracking, map_system, persistent_state, room_transition, soft_locks."
---

# Genre: Metroidvania

Expert blueprint for Metroidvanias balancing exploration, progression, and backtracking rewards.

## NEVER Do (Expert Anti-Patterns)

### World Design & Exploration
- NEVER allow "Soft-Locks" where a player is trapped; if they enter via a one-way path ("valve"), they MUST be able to leave using current abilities. Always design **fail-safe escape routes**.
- NEVER create empty dead ends; if a player backtracks to a remote area, they MUST be rewarded with a collectible, lore, or currency. Empty rooms are design failures.
- NEVER make backtracking purely repetitive; as the player gains movement (Dash/Teleport), traversal through old areas MUST become faster. **Open shortcuts** to bypass long, early routes.
- NEVER hide the critical path without "crumbs"; use distinct **Landmarks**, unique lighting, or environmental storytelling to build the player's mental map.
- NEVER design abilities that serve only one purpose; strictly implement dual-use traversal and combat functionality (e.g., a "Dash" that crosses gaps and dodges attacks).

### Persistence & Mapping
- NEVER forget to save **persistent room state**; if a player opens a chest or defeats a boss, that state MUST remain saved when they leave and return.
- NEVER load interconnected rooms synchronously via `load()`; strictly use `ResourceLoader.load_threaded_request()` for seamless transitions.
- NEVER track global progression within localized room scripts; strictly use **Autoload Singletons** for global ability flags and world state.
- NEVER use floating-point types for grid coordinates (minimaps/fog); strictly use `Vector2i` to prevent precision jitter.
- NEVER manipulate the SceneTree directly from a background loading thread; strictly use `call_deferred()`.

### Physics & Controls
- NEVER calculate jump arcs or dashes inside `_process()`; strictly use `_physics_process()` to prevent stutter.
- NEVER multiply `CharacterBody2D` velocity by `delta` before `move_and_slide()`; the engine handles this internally.
- NEVER poll `is_action_just_pressed()` inside `_physics_process()` for buffering; strictly capture events in `_unhandled_input()`.
- NEVER use standard strings for high-frequency ability checks; strictly use `StringName` (&"dashing") for pointer-speed comparisons.
- NEVER iterate through every node to broadcast updates; strictly use `SceneTree.call_group()` for efficient mass communication.
- NEVER delete active room/player nodes via `free()`; strictly use `queue_free()` to avoid segmentation faults.

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [minimap_fog.gd](scripts/minimap_fog.gd) - Grid-based fog of war that tracks visited rooms and persists via global save data.
- [progression_gate_manager.gd](scripts/progression_gate_manager.gd) - Central manager for ability-gated progression (Locks/Keys) and world persistence.

### Modular Components
- [platformer_jump_buffer.gd](scripts/platformer_jump_buffer.gd) - Modular coyote time and jump buffering for high-fidelity movement.
- [background_room_streamer.gd](scripts/background_room_streamer.gd) - Thread-safe background room preloading using `ResourceLoader`.
- [safe_scene_switcher.gd](scripts/safe_scene_switcher.gd) - Deferred scene transition pattern for stable cross-room world-state switching.
- [minimap_fog_revealer.gd](scripts/minimap_fog_revealer.gd) - Vector2i-based fog-of-war clearing logic synced to player position.
- [persistent_progression_system.gd](scripts/persistent_progression_system.gd) - Autoload pattern for tracking global ability/collectible flags.
- [ability_state_machine.gd](scripts/ability_state_machine.gd) - Optimized `StringName` pattern matching for traversal/combat states.
- [fast_wall_detector.gd](scripts/fast_wall_detector.gd) - Direct `PhysicsServer` queries for performance-optimized wall detection.
- [save_station_broadcast.gd](scripts/save_station_broadcast.gd) - Group-based entity resetting and healing logic on save interaction.
- [decoupled_hazard_logic.gd](scripts/decoupled_hazard_logic.gd) - Interface-style pattern for generic damage interaction.
- [smooth_room_camera_transition.gd](scripts/smooth_room_camera_transition.gd) - Tween-based camera limit interpolation for seamless room movement.

---

## Core Loop
1.  **Exploration**: Player explores available rooms until blocked by a "lock" (obstacle).
2.  **Discovery**: Player finds a "key" (ability/item) or boss.
3.  **Acquisition**: Player gains new traversal or combat ability.
4.  **Backtracking**: Player returns to previous locks with new ability.
5.  **Progression**: New areas open up, cycle repeats.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Character | `godot-characterbody-2d`, `state-machines` | Tight, responsive movement (Coyote time, buffers) |
| 2. World | `godot-tilemap-mastery`, `level-design` | Interconnected map, biomes, landmarks |
| 3. Systems | `godot-save-load-systems`, `godot-scene-management` | Persistent world state, room transitions |
| 4. UI | `ui-system`, `godot-inventory-system` | Map system, inventory, HUD |
| 5. Polish | `juiciness` | Effects, atmosphere, environmental storytelling |

## Architecture Overview

### 1. Game State & Persistence
Metroidvanias require tracking the state of every collectible and boss across the entire world.

```gdscript
# game_state.gd (AutoLoad)
extends Node

var collected_items: Dictionary = {} # "room_id_item_id": true
var unlocked_abilities: Array[String] = []
var map_visited_rooms: Array[String] = []

func register_collectible(id: String) -> void:
    collected_items[id] = true
    save_game()

func has_ability(ability_name: String) -> bool:
    return ability_name in unlocked_abilities
```

### 2. Room Transitions
Seamless transitions are key. Use a `SceneManager` to handle instancing new rooms and positioning the player.

```gdscript
# door.gd
extends Area2D

@export_file("*.tscn") var target_scene_path: String
@export var target_door_id: String

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        SceneManager.change_room(target_scene_path, target_door_id)
```

### 3. Ability System (State Machine Integration)
Abilities should be integrated into the player's State Machine.

```gdscript
# player_state_machine.gd
func _physics_process(delta):
    if Input.is_action_just_pressed("jump") and is_on_floor():
        transition_to("Jump")
    elif Input.is_action_just_pressed("jump") and not is_on_floor() and GameState.has_ability("double_jump"):
        transition_to("DoubleJump")
    elif Input.is_action_just_pressed("dash") and GameState.has_ability("dash"):
        transition_to("Dash")
```

## Key Mechanics Implementation

### Map System
A grid-based or node-based map is essential for navigation.
*   **Grid Map**: Auto-fill cells based on player position.
*   **Room State**: Track "visited" status to reveal map chunks.

```gdscript
# map_system.gd
func update_map(player_pos: Vector2) -> void:
    var grid_pos = local_to_map(player_pos)
    if not grid_map_data.has(grid_pos):
        grid_map_data[grid_pos] = VISITED
        ui_map.reveal_cell(grid_pos)
```

### Ability Gating (The "Lock")
Obstacles that check for specific abilities.

```gdscript
# breakable_wall.gd
extends StaticBody2D

@export var required_ability: String = "super_missile"

func take_damage(amount: int, ability_type: String) -> void:
    if ability_type == required_ability:
        destroy()
    else:
        play_deflect_sound()
```

## Common Pitfalls

1.  **Softlocks**: Ensure the player cannot get stuck in an area without the ability to leave. Design "valves" (one-way drops) carefully.
2.  **Backtracking Tedium**: Make backtracking interesting by changing enemies, opening shortcuts, or making traversal faster with new abilities.
3.  **Empty Rewards**: Every dead end should have a reward (health upgrade, lore, currency).
4.  **Lost Players**: Use visual landmarks and environmental storytelling to guide players without explicit markers (e.g., "The Statue Room").

## Godot-Specific Tips

*   **Camera2D**: Use `limit_left`, `limit_top`, etc., to confine the camera to the current room bounds. Update these limits on room transition.
*   **Resource Preloading**: Preload adjacent rooms for seamless open-world feel if not using hard transitions.
*   **RemoteTransform2D**: Use this to have the camera follow the player but stay detached from the player's rotation/scale.
*   **TileMap Layers**: Use separate layers for background (parallax), gameplay (collisions), and foreground (visual depth).

## Design Principles (from Dreamnoid)

*   **Ability Versatility**: Abilities should serve both traversal and combat (e.g., a dash that dodges attacks and crosses gaps).
*   **Practice Rooms**: Introduce a mechanic in a safe environment before testing the player in a dangerous one.
*   **Landmarks**: Distinct visual features help players build a mental map.
*   **Item Descriptions**: Use them for "micro-stories" to build lore without interrupting gameplay.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
