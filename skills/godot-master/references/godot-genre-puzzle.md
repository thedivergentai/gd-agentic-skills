> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Puzzle**. Accessed via Godot Master.

# Genre: Puzzle

Expert blueprint for building logic, grid-based, and physics puzzle games. Focuses on undo systems (Command Pattern), non-verbal tutorials, and robust grid-logic validation.

## Available Scripts

### [command_undo_redo.gd](../scripts/godot-genre-puzzle_command_undo_redo.gd)
The definitive implementation for puzzle game undo/redo logic. Uses the **Command Pattern** to store history items, allowing players to experiment freely without the fear of making a permanent mistake. Includes a ready-to-use `MoveCommand` template.

### [grid_manager.gd](../scripts/godot-genre-puzzle_grid_manager.gd)
A high-performance grid data structure for logic puzzles (Sokoban, Match-3). Decouples the game's logical state (which object is at which coordinate) from the visual rendering, providing functions for raycast-free move validation and object interaction.


## NEVER Do

- **NEVER punish player experimentation** — Puzzle games are about testing hypotheses. If a mistake requires a full level restart, the player will become ultra-cautious and stop having fun. Always provide an **Undo** or **Reset** button that is quick and painless to use.
- **NEVER require pixel-perfect input for logic puzzles** — If a puzzle is about "finding the right path," don't make the player struggle with precise mouse clicks or jittery platforming. Use **Grid Snapping** or large, forgiving hitboxes.
- **NEVER allow undetected "Soft-Locks"** — If a player pushes a block into a corner where it's impossible to solve the puzzle, they must be notified immediately OR provide a clear way to backtrack. Avoid letting them play for 10 minutes in an unsolvable state.
- **NEVER hide the rules of the world** — Visual feedback must be instant and unambiguous. If a cable carries power, it should glow. If a key fits a door, they should match in color or symbol. A player should never ask "Why did that happen?"
- **NEVER skip the Non-Verbal Tutorial phase** — Do not use walls of text to explain mechanics. Level 1 should introduce the mechanic in isolation; Level 2 should require its trivial use; Level 3 should combine it with something existing.
- **NEVER use `_process()` for grid-state validation** — Win conditions (e.g., "Are all blocks on targets?") should only be checked when a piece moves, not 60 times a second.

---

## Undo System (Command Pattern)
Traditional implementation:
1. **Command Object**: Encapsulates `execute()` and `undo()`.
2. **History Stack**: An `Array` of these objects.
3. **Undo Action**: Pop the top command and call its `undo()` method.
4. **Juice**: When undoing, use a `Tween` to smoothly move the objects back rather than snapping.

## Grid Interaction (Tile-Based)
For games like *Sokoban*:
- Maintain a 2D `Array` (or `Dictionary` for sparse grids) of the current game state.
- Before moving, check the target cell:
  - If **Wall**: Blocked.
  - If **Box**: Check if the space *behind* the box is empty (Push logic).
  - If **Empty**: Move.

## Teaching Mechanics (The Nintendo Method)
Level progression logic:
- **Introduce**: New element in a safe environment.
- **Develop**: Use the element to reach an exit.
- **Twist**: Use the element in an unexpected way (e.g., as a shield or weight).
- **Conclusion**: Combine with everything learned so far for a "Final Exam" level.

## Board State Validation
To check if the puzzle is solved:
- Event: `unit_moved`
- Action: Loop through all `TargetZone` nodes and check for `is_occupied`.
- Feedback: Play a "Victory" chime and open the exit portal.

## Reference
- [Godot Docs: Grid-based movement with Tweens](https://docs.godotengine.org/en/stable/classes/class_tween.html)
- [GDC: The Design of Portals and Puzzles](https://www.youtube.com/watch?v=N_pE0O6X5F0)
