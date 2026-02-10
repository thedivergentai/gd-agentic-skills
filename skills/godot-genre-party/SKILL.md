---
name: godot-genre-party
description: "Expert blueprint for party games including minigame resource system (define via .tres files), local multiplayer input (4-player controller management), asymmetric gameplay (1v3 balance), scene management (clean minigame loading/unloading), persistent scoring (track wins across rounds), and split-screen rendering (SubViewport per player). Use for Mario Party-style games or WarioWare collections. Trigger keywords: party_game, minigame_collection, local_multiplayer, asymmetric_gameplay, split_screen, dynamic_input_mapping."
---

# Genre: Party / Minigame Collection

Expert blueprint for party games balancing accessibility, variety, and social fun.

## NEVER Do

- **NEVER long tutorials** — Players want instant fun. 3-second looping GIF + 1-sentence instruction is ideal.
- **NEVER excessive downtime** — Loading between 10s minigames kills momentum. Keep assets light, use threaded loading, or persistent board scene.
- **NEVER inconsistent controls** — Minigame A uses A to jump, B uses B. Standardize: A=Accept/Action, B=Back/Cancel across all minigames.
- **NEVER forget dynamic input mapping** — Remap InputMap at runtime (InputMap.action_add_event) for "p1_jump", "p2_jump" per controller.
- **NEVER ignore accessibility** — Color-blind modes, audio cues for visual events, adjustable difficulty. Party games need inclusive design.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [party_input_router.gd](scripts/party_input_router.gd)
4-player device isolation for local multiplayer. Maps device_id to player_id, handles join requests, routes inputs to player-specific signals.

---

## Core Loop
1.  **Lobby**: Players join and select characters/colors.
2.  **Meta**: Players move on a board or vote for the next game.
3.  **Play**: Short, intense minigame (30s - 2m).
4.  **Score**: Winners get points/coins.
5.  **Repeat**: Cycle continues until a turn limit or score limit.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Input | `input-mapping` | Handling 2-4 local controllers dynamically |
| 2. Scene | `godot-scene-management` | Loading/Unloading minigames cleanly |
| 3. Data | `godot-resource-data-patterns` | Defining minigames via Resource files |
| 4. UI | `godot-ui-containers` | Scoreboards, instructions screens |
| 5. Logic | `godot-turn-system` | Managing the "Board Game" phase |

## Architecture Overview

### 1. Minigame Definition
Using Resources to define what a minigame is.

```gdscript
# minigame_data.gd
class_name MinigameData extends Resource

@export var title: String
@export var scene_path: String
@export var instructions: String
@export var is_1v3: bool = false
@export var thumbnail: Texture2D
```

### 2. The Party Manager
Singleton that persists between minigames.

```gdscript
# party_manager.gd
extends Node

var players: Array[PlayerData] = [] # Tracks score, input_device_id, color
var current_round: int = 1
var max_rounds: int = 10

func start_minigame(minigame: MinigameData) -> void:
    # 1. Show instructions scene
    await show_instructions(minigame)
    # 2. Transition to actual game
    get_tree().change_scene_to_file(minigame.scene_path)
    # 3. Pass player data to the new scene
    # (The minigame scene must look up PartyManager in _ready)
```

### 3. Minigame Base Class
Every minigame inherits from this to ensure compatibility.

```gdscript
# minigame_base.gd
class_name Minigame extends Node

signal game_ended(results: Dictionary)

func _ready() -> void:
    setup_players(PartyManager.players)
    start_countdown()

func end_game() -> void:
    # Calculate winner
    game_ended.emit(results)
    PartyManager.handle_minigame_end(results)
```

## Key Mechanics Implementation

### Local Multiplayer Input
Handling dynamic device assignment.

```gdscript
# player_controller.gd
@export var player_id: int = 0 # 0, 1, 2, 3

func _physics_process(delta: float) -> void:
    var device = PartyManager.players[player_id].device_id
    # Use the specific device ID for input
    var direction = Input.get_vector("p%s_left" % player_id, ...) 
    # Better approach: Remap InputMap actions at runtime explicitly
```

### Asymmetric Gameplay (1v3)
Balancing the "One" vs the "Many".
*   **The One**: Powerful, high HP, unique abilities (e.g., Bowser suit).
*   **The Many**: Weak individually, must cooperate to survive/win.

## Godot-Specific Tips

*   **SubViewport**: Powerful for 4-player split-screen. Each player gets a camera, all rendering the same world (or different worlds!).
*   **InputEventJoypadButton**: Use `Input.get_connected_joypads()` to auto-detect controllers on the Lobby screen.
*   **Remapping**: Godot's `InputMap` system can be modified at runtime using `InputMap.action_add_event()`. Creating "p1_jump", "p2_jump" dynamically is a common pattern.

## Common Pitfalls

1.  **Long Tutorials**: Players just want to play. **Fix**: 3-second looping GIF + 1 sentence instruction overlay before the game starts.
2.  **Downtime**: Loading times between 10-second minigames. **Fix**: Keep minigame assets light. Use a "Board" scene that stays loaded in the background if possible, or use creating `Thread` loading.
3.  **Confusing Controls**: Minigame A uses "A" to jump, Minigame B uses "B". **Fix**: Standardize. "A" is always Accept/Action. "B" is always Back/Cancel.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
