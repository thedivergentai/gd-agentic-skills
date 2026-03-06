# Time Trial Loop: Arcade Precision

> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Time Trial Loops**. Accessed via Godot Master.

## Architectural Thinking: The "Validation-Chain" Pattern

A Master implementation treats Time Trials as a **State-Validated Sequence**. Recording a time is easy; ensuring the player didn't cheat requires strictly ordered checkpoints.

### Core Responsibilities
- **Manager**: The central clock. Validates checkpoint order.
- **Recorder**: Captures high-frequency transform data at ~10Hz.
- **Replayer**: Plays back ghost data using `lerp` for smooth 60fps+ visuals.

## Expert Code Patterns

### 1. Robust Checkpoint Validation
```gdscript
# game_loop_time_trial_manager.gd snippet
func pass_checkpoint(index):
    if index == current_checkpoint_index + 1:
        current_checkpoint_index = index
```

### 2. Space-Efficient ghosting
Sample at 10Hz and interpolate.
```gdscript
# game_loop_time_trial_replayer.gd
var weight = (playback_time - frame_a.t) / (frame_b.t - frame_a.t)
var target_pos = frame_a.p.lerp(frame_b.p, weight)
```

## NEVER Do
- **NEVER use `Time.get_ticks_msec()`** for physics-sensitive logic. Use `delta`.
- **NEVER use `Area3D` without monitoring optimization**. 
- **NEVER record the whole object**. Only record `position` and `rotation`.

## Registry
- **Expert Component**: [game_loop_time_trial_manager.gd](../scripts/game_loop_time_trial_manager.gd)
- **Expert Component**: [game_loop_time_trial_recorder.gd](../scripts/game_loop_time_trial_recorder.gd)
- **Expert Component**: [game_loop_time_trial_replayer.gd](../scripts/game_loop_time_trial_replayer.gd)
