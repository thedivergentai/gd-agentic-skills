---
name: godot-game-loop-time-trial
description: Expert patterns for racing mechanics, checkpoint tracking, and ghost recording/playback in Godot 4. Use when building racing games, speed-run platformers, or arcade trials.
---

# Time Trial Loop: Arcade Precision

> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Time Trial Loops**. Accessed via Godot Master.

## Architectural Thinking: The "Validation-Chain" Pattern

A Master implementation treats Time Trials as a **State-Validated Sequence**. Recording a time is easy; ensuring the player didn't cheat via shortcuts requires a strictly ordered `CheckpointManager`.

### Core Responsibilities
- **TimeTrialManager**: The central clock. Validates checkpoint order and handles "Best Lap" logic.
- **GhostRecorder**: Captures high-frequency transform data. Uses delta-time timestamps for frame-independent playback.
- **Checkpoint**: Spatial triggers that notify the Manager.

## Expert Code Patterns

### 1. Robust Checkpoint Validation
Prevent "Shortcut Cheating" by requiring checkpoints to be cleared in numerical order.

```gdscript
# time_trial_manager.gd snippet
func pass_checkpoint(index):
    if index == current_checkpoint_index + 1:
        current_checkpoint_index = index
        _emit_split_time()
```

### 2. Space-Efficient Ghosting
Avoid recording every frame. Sample the player's position at a fixed rate (e.g., 10Hz) and use **Linear Interpolation (lerp)** during playback to fill the gaps.

```gdscript
# ghost_replayer.gd (Conceptual)
func _process(delta):
    # Uses linear interpolation for smooth 60fps+ playback from 10hz data
    var target_pos = frame_a.p.lerp(frame_b.p, weight)
```

## Master Decision Matrix: Data Storage

| Format | Best For | Implementation |
| :--- | :--- | :--- |
| **Dictionary Array** | Prototyping | Simple `[{t: 0.1, p: pos}, ...]` |
| **Typed Array** | Performance | `PackedVector3Array` for positions. |
| **JSON/Binary** | Saving | `FileAccess.get_var()` to save ghost files. |

## Veteran-Only Gotchas (Never List)

- **NEVER use `Time.get_ticks_msec()`** for physics-sensitive race logic. Use `_process(delta)` or `_physics_process(delta)` to stay in sync with the engine's time scale.
- **NEVER use `Area3D` without monitoring optimization**. Checkpoints should only look for the `Player` layer.
- **NEVER record the whole object**. Only record `position` and `rotation`. Input-state recording is better for determinism but harder to implement in Godot's physics.
- **Juice**: Ghost should be semi-transparent and have no collision to prevent distracting the player.

## Registry

- **Expert Component**: [time_trial_manager.gd](scripts/time_trial_manager.gd)
- **Expert Component**: [ghost_recorder.gd](scripts/ghost_recorder.gd)
- **Expert Component**: [ghost_replayer.gd](scripts/ghost_replayer.gd)
