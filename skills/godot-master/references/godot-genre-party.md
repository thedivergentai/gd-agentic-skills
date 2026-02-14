> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Party / Minigame Collection**. Accessed via Godot Master.

# Genre: Party / Minigame Collection

Expert blueprint for building party games and minigame collections. Focuses on local 4-player multiplayer management, rapid-fire scene transitions, and persistent meta-game scoring.

## Available Scripts

### [party_input_router.gd](../scripts/godot-genre-party_party_input_router.gd)
A professional input management solution for local multiplayer. Handles dynamic device-to-player assignment (mapping `device_id` to `player_id`), routes inputs to isolated signals, and provides a "Click to Join" lobby pattern.


## NEVER Do

- **NEVER use long text-based tutorials** — Party games are social; players want to play immediately. Use a **3-second looping GIF** + a single-sentence instruction (e.g., "Mash A to fly!") rather than walls of text.
- **NEVER allow inconsistent controls between games** — If Minigame A uses 'A' to jump, and Minigame B uses 'B', players will get frustrated. Standardize your controls: **A = Accept/Action**, **B = Back/Cancel**, **Joystick = Move** across all games.
- **NEVER ignore "Asymmetric" balance** — In 1v3 minigames, the "One" must feel powerful but not invincible. Provide the single player with more HP or unique abilities to offset the numerical disadvantage of the trio.
- **NEVER bake player-IDs into the input map** — Avoid hardcoding "p1_jump" and "p2_jump" in the editor. Instead, use a **Dynamic Input Router** that remaps actions based on the specific controller IDs connected at runtime.
- **NEVER neglect "Accessibility" and Handicap systems** — Party games are played by varying skill levels. Implement optional handicaps (e.g., more speed for children/new players) to keep the competition social and fun.
- **NEVER use heavy scene transitions** — Loading a 30MB scene for a 10-second minigame will kill the party's momentum. Keep assets highly optimized and use **Threaded Background Loading** while the instructions screen is active.

---

## Local Multiplayer Orchestration
1. **The Lobby**: Detect `InputEventJoypadButton`. Assign the first controller to hit 'Start' as Player 1.
2. **Persistence**: Use an AutoLoad (`PartyManager`) to store an `Array[PlayerData]` containing scores, colors, and assigned device IDs.
3. **Player Spawning**: In each minigame's `_ready()`, loop through the `PartyManager` and instantiate the appropriate number of player actors.

## Using SubViewports for Split-Screen
For games requiring individual perspectives:
- Create a `GridContainer`.
- Add a `SubViewportContainer` for each active player.
- Assign a `Camera3D` or `Camera2D` to each viewport that follows only that player's ID.

## Defining Minigames via Resources
Create a `MinigameData` Resource:
- `title`: String
- `scene`: PackedScene
- `instructions`: String
- `score_weight`: float
This allows you to add new games to the collection by simply dropping a new `.tres` file into the `MinigameRegistry`.

## Rapid-Fire Instruction Flow
1. **Stage 1**: Show the Minigame Title and GIF for 5 seconds.
2. **Stage 2**: "3... 2... 1... GO!" overlay.
3. **Stage 3**: Gameplay (30-60 seconds).
4. **Stage 4**: "Winner: Player 2" celebration.
5. **Stage 5**: Update score and return to the Board or Main Menu.

## Reference
- [Godot Docs: Multiple Viewports](https://docs.godotengine.org/en/stable/tutorials/rendering/viewports.html)
- [Design Architecture of WarioWare (Game Developer)](https://www.gamedeveloper.com/design/the-design-architecture-of-warioware)
