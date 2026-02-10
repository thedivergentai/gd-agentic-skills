---
name: godot-genre-puzzle
description: "Expert blueprint for puzzle games including undo systems (Command pattern for state reversal), grid-based logic (Sokoban-style mechanics), non-verbal tutorials (teach through level design), win condition checking, state management, and visual feedback (instant confirmation of valid moves). Use for logic puzzles, physics puzzles, or match-3 games. Trigger keywords: puzzle_game, undo_system, command_pattern, grid_logic, non_verbal_tutorial, state_management."
---

# Genre: Puzzle

Expert blueprint for puzzle games emphasizing clarity, experimentation, and "Aha!" moments.

## NEVER Do

- **NEVER punish experimentation** — Puzzles are about testing ideas. Always provide undo/reset. No punishment for trying.
- **NEVER require pixel-perfect input** — Logic puzzles shouldn't need precision aiming. Use grid snapping or forgiving hitboxes.
- **NEVER allow undetected unsolvable states** — Detect softlocks automatically or provide prominent "Reset Level" button.
- **NEVER hide the rules** — Visual feedback must be instant and clear. A wire lighting up when connected teaches the rule.
- **NEVER skip non-verbal tutorials** — Level 1 = introduce mechanic in isolation. Level 2 = trivial use. Level 3 = combine with existing mechanics.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [command_undo_redo.gd](scripts/command_undo_redo.gd)
Command pattern for undo/redo. Stores reversible actions in dual stacks, clears redo on new action. Includes MoveCommand example.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)
