> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Platformer**. Accessed via Godot Master.

# Genre: Platformer

Expert blueprint for 2D and 3D platforming games. Focuses on movement precision (Coyote Time, Jump Buffering), game feel (Polish), and level design principles for maximum player engagement.

## Available Scripts

### [advanced_platformer_controller.gd](../scripts/godot-genre-platformer_advanced_platformer_controller.gd)
A professional-grade `CharacterBody2D` controller. Includes all industry-standard feel features: Coyote Time, Jump Buffering, variable jump height, apex float, and wall-sliding/jumping logic.


## NEVER Do

- **NEVER skip Coyote Time** — Without a small grace window (approx 0.1s) after walking off a ledge, jumps will feel unresponsive. Players will feel like their inputs were "eaten" by the engine.
- **NEVER ignore Jump Buffering** — If a player presses jump right before they hit the ground, they expect to jump the instant they land. Ignoring this leads to a "heavy" or "clunky" control feel.
- **NEVER use a fixed jump height** — Modern platformers require variable jump heights (tap for a hop, hold for a high jump). This allows for much higher precision and player expression.
- **NEVER use linear camera snapping** — A camera that snaps instantly to the player causes significant eye strain and motion sickness. Use `position_smoothing` (Camera2D) or Lerp functions.
- **NEVER skip Squash and Stretch** — Landing from a high fall without visual impact feels weightless. Adding a tiny squash on landing and a stretch on jump adds "juice" to the movement.
- **NEVER create "Blind Jumps"** — If a player has to jump downward into a space they cannot see, it is poor level design. Use camera look-ahead or zoom-out triggers to reveal the safe landing area.

---

## The "Celeste" Pattern (Movement Feel)
High-precision platformers rely on several mathematical "cheats" to feel good:
1. **Coyote Time**: Buffer the `is_on_floor()` state for a few frames.
2. **Jump Buffer**: Store the `jump_pressed` variable for a few frames if the player isn't grounded yet.
3. **Apex Float**: Slightly reduce gravity at the very peak of a jump to give the player more air control for precise landings.

## Level Design: The Teaching Trilogy
Introduce new mechanics in three stages:
- **Safety**: A room where the player can't die while learning the new skill.
- **Challenge**: The player must use the skill to avoid a hazard or cross a gap.
- **Twist**: Combining the new skill with a previously learned one (e.g., wall-jumping + double-jump).

## World-Space UI
For platformers, keep UI close to the action:
- Display collectible counts in a world-space HUD.
- Use **Floating Combat Text** (RichTextLabel) for damage numbers or picked-up items.
- Ensure the HUD doesn't occlude the player's view of the next platform.

## Performance for Precision
Input lag is the enemy of platforming.
- Use `_physics_process` for all movement logic.
- Ensure the physics tick rate (Default 60) matches or exceeds the target refresh rate for high-end monitors.
- Avoid heavy screen-space shaders that might cause frame-drops during intense platforming sequences.

## Reference
- [Godot Docs: 2D Movement Overview](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)
- [GDC: The Art of Screenshake and Game Feel](https://www.youtube.com/watch?v=AJdEqssNZ-U)
