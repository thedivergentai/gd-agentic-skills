> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Project Templates & Scaffolding**. Accessed via Godot Master.

# Project Templates

Expert blueprint for bootstrapping Godot projects with standardized directory structures, core AutoLoads, and best-practice system architectures for various genres (Platformer, RPG, FPS).

## Available Scripts

### [base_game_manager.gd](../scripts/project_templates_base_game_manager.gd)
A versatile `AutoLoad` template designed to serve as the brain of any Godot project. Handles global state (Lives, Score, Level Progress), manages scene transitions, and coordinates game-wide pausing logic through signals.


## NEVER Do

- **NEVER hardcode scene paths in scripts** — Do not call `change_scene_to_file("res://levels/level_1.tscn")` from inside a player or enemy script. This makes refactoring a directory structure impossible later. Store levels in a `Dictionary` within your `GameManager` and call them by short names (e.g., "Level_1").
- **NEVER forget to register AutoLoads** — Including a script in the `autoloads/` folder does not make it a global singleton. You MUST manually add it in **Project Settings -> Autoload** with the correct node name.
- **NEVER pause the entire SceneTree without groups** — Using `get_tree().paused = true` will freeze everything, including your Pause Menu and UI animations. Set the **Process Mode** of your UI layer to `ALWAYS` and your gameplay layers to `PAUSABLE`.
- **NEVER skip Input Map standardization** — Don't use different names for "Jump" in different projects (e.g., "ui_select" vs "player_jump"). Stick to a standard convention across all templates: `move_left`, `move_right`, `jump`, `interact`, `pause`.
- **NEVER leave the mouse uncaptured in 3D FPS** — A standard mistake in FPS templates is leaving the mouse cursor visible. ALWAYS call `Input.mouse_mode = Input.MOUSE_MODE_CAPTURED` in the first frame of gameplay.

---

## Standardized Directory Structure
A clean project is a healthy project:
- **/assets**: Raw assets (3D models, textures, .wav).
- **/autoloads**: Global manager scripts.
- **/entities**: Subfolders for Player, Enemies, NPCs.
- **/scenes**: Top-level UI and Game containers.
- **/levels**: The actual `.tscn` world files.
- **/resources**: Custom `.tres` and `.gd` data classes.

## The Global Game Manager Pattern
The `GameManager` should be the source of truth for:
- **Game State**: `enum { MENU, PLAYING, WIN, GAMEOVER }`
- **Session Data**: The shared resource tracking the current player's progress.
- **Input Forwarding**: Handling global actions like "Quick Save" or "Mute All."

## Scene Navigation Service
To manage a complex project, create a Dedicated `SceneTransition` singleton:
1. `fade_out()` (Animated overlay).
2. `get_tree().change_scene_to_file()`.
3. `fade_in()`.

## Template Variants
- **2D Platformer**: Focuses on `CharacterBody2D`, TileMaps, and parallax backgrounds.
- **Top-Down RPG**: Focuses on `NavigationAgent2D`, Dialogue systems, and Grid-based inventories.
- **3D FPS**: Focuses on `VehicleBody3D` (optional), High-speed 3D physics, and advanced lighting.

## Configuration (Project.godot)
Essential tweaks for every boilerplate:
- **Display/Window**: Set target resolution and Stretch Mode (Viewport for 2D, Canvas for UI-only).
- **Physics**: Enable "Continuous CD" for high-speed games.
- **Rendering**: Set default Clear Color and Environment.

## Reference
- [Godot Docs: Project Organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)
- [Godot Docs: Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
