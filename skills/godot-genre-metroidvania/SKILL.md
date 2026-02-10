---
name: godot-genre-metroidvania
description: "Expert blueprint for Metroidvanias including ability-gated exploration (locks/keys), interconnected world design (backtracking with shortcuts), persistent state tracking (collectibles, boss defeats), room transitions (seamless loading), map systems (grid-based revelation), and ability versatility (combat + traversal). Use for exploration platformers or action-adventure games. Trigger keywords: metroidvania, ability_gating, interconnected_world, backtracking, map_system, persistent_state, room_transition, soft_locks."
---

# Genre: Metroidvania

Expert blueprint for Metroidvanias balancing exploration, progression, and backtracking rewards.

## NEVER Do

- **NEVER allow soft-locks** — Players must always have ability to backtrack. Design "valves" (one-way drops) carefully with escape routes.
- **NEVER make empty dead ends** — Every path should have a reward (upgrade, lore, currency). Empty rooms waste player time.
- **NEVER make backtracking tedious** — New abilities should speed traversal (dash, teleport). Or unlock shortcuts connecting distant areas.
- **NEVER forget persistent state** — Save collectible pickup status globally. If player collects item in Room A, it must stay collected after leaving.
- **NEVER hide critical path without breadcrumbs** — Use landmarks, environmental storytelling, or subtle visual cues. Players should build mental maps.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [minimap_fog.gd](scripts/minimap_fog.gd)
Grid-based fog-of-war for minimap. Tracks revealed tiles via player position, draws only visited rooms. Scalable via TileMap for large maps.

### [progression_gate_manager.gd](scripts/progression_gate_manager.gd)
Ability unlock + world persistence system. Tracks unlocked abilities and room states (doors, bosses), enables global collision gate updates.

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
