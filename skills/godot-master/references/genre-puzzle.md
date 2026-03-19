---
name: godot-genre-puzzle
description: "Expert blueprint for puzzle games including undo systems (Command pattern for state reversal), grid-based logic (Sokoban-style mechanics), non-verbal tutorials (teach through level design), win condition checking, state management, and visual feedback (instant confirmation of valid moves). Use for logic puzzles, physics puzzles, or match-3 games. Trigger keywords: puzzle_game, undo_system, command_pattern, grid_logic, non_verbal_tutorial, state_management."
---

# Genre: Puzzle

Expert blueprint for puzzle games emphasizing clarity, experimentation, and "Aha!" moments.

## NEVER Do (Expert Anti-Patterns)

### Design & Player Experience
- NEVER punish experimentation; strictly provide **Undo/Reset** functionality to allow risk-free hypothesis testing.
- NEVER require pixel-perfect input for logic puzzles; strictly use **Grid Snapping** or large, forgiving hitboxes.
- NEVER allow undetected **Soft-Locks** (unsolvable states); strictly notify the player or provide immediate backtracking.
- NEVER hide the rules of the world; strictly ensure visual feedback is instant and unambiguous (e.g., powered wires must glow).
- NEVER skip the **Non-Verbal Tutorial** phase; strictly introduce mechanics in isolation before combining them.

### Grid Logic & State
- NEVER use floating-point numbers (`Vector2`) for grid coordinates; strictly use **Vector2i** to prevent precision drift.
- NEVER use `_process()` for grid-state or win-condition validation; strictly trigger checks only when a piece moves.
- NEVER rely on the `SceneTree` structure as the source of truth; strictly maintain grid data in a separate script/dictionary.
- NEVER modify a Dictionary or Array size while iterating over it; strictly use a copy or a separate queue for modifications.
- NEVER calculate heavy recursive solvers in `_process()`; strictly cache results or use threaded workers for solve-checks.
- NEVER ignore diagonal rules in pathfinding; strictly configure `AStarGrid2D.diagonal_mode` correctly.

### Architecture & Performance
- NEVER program custom command history queues manually; strictly use Godot's built-in **UndoRedo** system for reliability.
- NEVER intermingle "do" and "undo" logic in the same function; strictly maintain separation for predictable rollbacks.
- NEVER use exact floating-point equality (==); strictly use `is_equal_approx()` for spatial constraints.
- NEVER use `load()` for resetting large rooms dynamically; strictly use `ResourceLoader.load_threaded_request()`.
- NEVER leave **Tween** objects unreferenced; strictly kill active tweens before starting new movement on the same object.

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [command_undo_redo.gd](../scripts/genre_puzzle_command_undo_redo.gd) - Professional-grade Command Pattern for non-destructive state reversal and experimentation.
- [grid_manager.gd](../scripts/genre_puzzle_grid_manager.gd) - Decoupled grid logic data structure for raycast-free move validation (Sokoban/Match-3).

### Modular Components
- [puzzle_pathfinder.gd](../scripts/genre_puzzle_puzzle_pathfinder.gd) - AStarGrid2D configuration for optimized pathfinding on 2D grids.
- [puzzle_history.gd](../scripts/genre_puzzle_puzzle_history.gd) - UndoRedo system implementation using the Action Command pattern.
- [puzzle_saver.gd](../scripts/genre_puzzle_puzzle_saver.gd) - JSON-based serialization for saving/restoring complex puzzle states.
- [shuffle_bag.gd](../scripts/genre_puzzle_shuffle_bag.gd) - Non-repeating randomizer for fair distribution of puzzle elements.
- [perspective_overlay.gd](../scripts/genre_puzzle_perspective_overlay.gd) - 3D-to-2D projection bridge for world-space puzzle mechanics.
- [tile_animator.gd](../scripts/genre_puzzle_tile_animator.gd) - Safe tween-based movement system using Callables for logic sync.
- [match_three_logic.gd](../scripts/genre_puzzle_match_three_logic.gd) - Recursive flood-fill and match detection logic.
- [grid_input_manager.gd](../scripts/genre_puzzle_grid_input_manager.gd) - Device-agnostic input routing for grid interaction.
- [sleepy_block.gd](../scripts/genre_puzzle_sleepy_block.gd) - Physics object stabilizer to prevent unintended solver jitter.
- [puzzle_validator.gd](../scripts/genre_puzzle_puzzle_validator.gd) - Array reduction component for evaluating complex win conditions.

---

## Core Loop
1.  **Observation**: Player assesses the level layout and mechanics.
2.  **Experimentation**: Player interacts with elements (push, pull, toggle).
3.  **Feedback**: Game reacts (door opens, laser blocked).
4.  **Epiphany**: Player understands the logic ("Aha!" moment).
5.  **Execution**: Player executes the solution to advance.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Interaction | `godot-input-handling`, `raycasting` | Clicking, dragging, grid movement |
| 2. Logic | `command-pattern`, `state-management` | Undo/Redo, tracking level state |
| 3. Feedback | `godot-tweening`, `juice` | Visual confirmation of valid moves |
| 4. Progression | `godot-save-load-systems`, `level-design` | Unlocking levels, tracking stars/score |
| 5. Polish | `ui-minimalism` | Non-intrusive HUD |

## Architecture Overview

### 1. Command Pattern (Undo System)
Essential for puzzle games. Never punish testing.

```gdscript
# command.gd
class_name Command extends RefCounted

func execute() -> void: pass
func undo() -> void: pass

# level_manager.gd
var history: Array[Command] = []
var history_index: int = -1

func commit_command(cmd: Command) -> void:
    # Clear redo history if diverging
    if history_index < history.size() - 1:
        history = history.slice(0, history_index + 1)
        
    cmd.execute()
    history.append(cmd)
    history_index += 1

func undo() -> void:
    if history_index >= 0:
        history[history_index].undo()
        history_index -= 1
```

### 2. Grid System (TileMap vs Custom)
For grid-based puzzles (Sokoban), a custom data structure is often better than just reading physics.

```gdscript
# grid_manager.gd
var grid_size: Vector2i = Vector2i(16, 16)
var objects: Dictionary = {} # Vector2i -> Node

func move_object(obj: Node, direction: Vector2i) -> bool:
    var start_pos = grid_pos(obj.position)
    var target_pos = start_pos + direction
    
    if is_wall(target_pos):
        return false
        
    if objects.has(target_pos):
        # Handle pushing logic here
        return false
        
    # Execute move
    objects.erase(start_pos)
    objects[target_pos] = obj
    tween_movement(obj, target_pos)
    return true
```

## Key Mechanics Implementation

### Win Condition Checking
Check victory state after every move.

```gdscript
func check_win_condition() -> void:
    for target in targets:
        if not is_satisfied(target):
            return
    
    level_complete.emit()
    save_progress()
```

### Non-Verbal Tutorials
Teach mechanics through level design, not text.
1.  **Isolation**: Level 1 introduces *only* the new mechanic in a safe room.
2.  **Reinforcement**: Level 2 requires using it to solve a trivial problem.
3.  **Combination**: Level 3 combines it with previous mechanics.

## Common Pitfalls

1.  **Strictness**: Requiring pixel-perfect input for logic puzzles. **Fix**: Use grid snapping or forgiving hitboxes.
2.  **Dead Ends**: Allowing the player to get into an unsolvable state without realizing it. **Fix**: Auto-detect failure or provide a prominent "Reset" button.
3.  **Obscurity**: Hiding the rules. **Fix**: Visual feedback must be instant and clear (e.g., a wire lights up when connected).

## Godot-Specific Tips

*   **Tweens**: Use `create_tween()` for all grid movements. It feels much better than instant snapping.
*   **Custom Resources**: Store level data (layout, starting positions) in `.tres` files for easy editing in the Inspector.
*   **Signals**: Use signals like `state_changed` to update UI/Visuals decoupled from the logic.


## Reference
- Master Skill: [godot-master](../SKILL.md)
