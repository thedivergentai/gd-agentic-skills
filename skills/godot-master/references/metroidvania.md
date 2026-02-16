> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Metroidvania**. Accessed via Godot Master.

# Genre: Metroidvania

Expert blueprint for interconnected world design. Focuses on ability-gated progression (locks and keys), persistent room states, and seamless world exploration through backtracking and shortcuts.

## Available Scripts

### [minimap_fog.gd](../scripts/metroidvania_minimap_fog.gd)
A grid-based map system that automatically tracks and reveals explored territory. Uses `TileMap` data to generate a persistent "Fog of War" discovery layer for the player's minimap.

### [progression_gate_manager.gd](../scripts/metroidvania_progression_gate_manager.gd)
Central manager for world persistence. Tracks which abilities are unlocked (e.g., Double Jump, Dash), which bosses have been defeated, and which doors/shortcuts have been permanently opened.


## NEVER Do

- **NEVER allow "Soft-Locks" where a player is trapped** — If a player enters an area using a one-way path (a "valve"), they MUST be able to leave it using the abilities they currently possess. Always design escape routes and fail-safe paths.
- **NEVER create empty dead ends** — If a player spends 5 minutes backtracking or navigating a difficult path to reach the end of a corridor, there MUST be a meaningful reward (a collectible, lore, or currency). Empty rooms are a failure of level design.
- **NEVER make backtracking purely repetitive** — As the player gains new movement abilities (Dash, Teleport), the act of traveling through old areas should become faster and easier. Additionally, open new shortcuts to bypass long, old routes.
- **NEVER forget to save persistent room state** — If a player opens a chest or defeats a mini-boss in Room A, that state must be saved globally. If they leave and return, the chest should remain open and the boss dead.
- **NEVER hide the critical path without "crumbs"** — Exploring is fun, but getting totally lost is frustrating. Use distinct **Landmarks**, unique lighting, or environmental storytelling (e.g., "The Statue Room") to help players build a mental map.
- **NEVER design abilities that only serve one purpose** — The best Metroidvania abilities are multi-functional. A "Dash" should cross large gaps (traversal) AND dodge enemy attacks (combat).

---

## Interconnected World Design
Metroidvanias are large maps connected by:
- **Major Gates**: Barriers that require a core ability (e.g., a high ledge needing Double Jump).
- **Minor Gates**: Obstacles needing a specific weapon type (e.g., a green door needing a Missiles).
- **Shortcuts**: One-way doors or breakable walls that connect late-game areas back to early hubs.

## Ability Gating Logic
Use the `progression_gate_manager.gd` alongside your player state machine:
```gdscript
if GameState.has_ability("dash") and Input.is_action_just_pressed("dash"):
    state_machine.transition_to("Dashing")
```

## Room Transitions
For a "seamless" feel:
1. Use an AutoLoad `SceneManager`.
2. Cross-fade or slide between rooms.
3. Position the player at the corresponding "Door" node in the new scene based on the ID of the door they just exited.

## Map and Fog of War
Implement a grid-based map where:
- Each "Room" corresponds to a block on a 2D grid.
- Reveling a room on the UI only happens once the player enters it.
- Save the `revealed_tiles` array to the global save file.

## AI and Boss Design
Metroidvania bosses should act as skill checks:
- A "Double Jump" boss should force the player to use their new jump to avoid low-sweeping attacks.
- A "Cloak" ability should be used to hide from a boss's spotlight or tracking laser.

## Reference
- [Godot Docs: Scene Tree Navigation](https://docs.godotengine.org/en/stable/tutorials/scripting/change_scenes_manually.html)
- [Game Maker's Toolkit: The Design of Hollow Knight](https://www.youtube.com/watch?v=02onA6O_9D4)
