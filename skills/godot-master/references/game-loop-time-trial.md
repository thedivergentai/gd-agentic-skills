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

## NEVER Do

- **NEVER use OS.get_ticks_msec() for ultra-precise race timing** — Millisecond resolution is too coarse for high-end racing games. Use `Time.get_ticks_usec()` for microsecond precision.
- **NEVER rely exclusively on _process() for finish line triggers** — Visual frames can skip during lag. Always evaluate physical overlaps in `_physics_process()` to guarantee detection within the fixed physics step.
- **NEVER evaluate Area3D overlaps immediately after instantiation** — The physics server requires at least one physics frame to synchronize. `await get_tree().physics_frame` before checking for players.
- **NEVER scale a CollisionShape3D on a checkpoint non-uniformly** — This breaks the underlying SAT collision math. Always scale the internal shape resource (e.g., `BoxShape3D.size`) instead.
- **NEVER use TCP (reliable) for syncing positions in multiplayer racing** — Congestion algorithms cause huge spikes. Use `ENetMultiplayerPeer` with `TRANSFER_MODE_UNRELIABLE` for high-frequency position updates.
- **NEVER trust client-side finish line/lap crossing** — Always validate triggers on the authoritative server using `multiplayer.is_server()` to prevent cheating.
- **NEVER use standard float equality (==) for record lap times** — Use `is_equal_approx()` to account for precision loss in accumulated time variables.
- **NEVER hardcode input checks without flushing the buffer** — For frame-perfect boost/stop responses, call `Input.flush_buffered_events()` to ensure the engine has processed the latest raw input.
- **NEVER allocate new Vector3 arrays inside fast path-following loops** — This triggers the garbage collector. Use `PackedVector3Array` to maintain a contiguous memory block.
- **NEVER use dynamic string paths ($"../Checkpoint") in tight loops** — Lookups are slow. Use `@onready` to cache node references during initialization.
- **NEVER record the whole player object for ghosts** — Only record core transforms (position/rotation). Recording the whole object is memory-intensive and unnecessary for visual ghosts.
- **NEVER give the ghost collision** — It should be a purely visual indicator (e.g., semi-transparent) to avoid disrupting the player's line.
- **NEVER neglect checkpoint sequencing** — Don't just check if the player hit the finish line. Verify they passed every intermediate checkpoint in the correct order.
- **NEVER use Area3D without monitoring optimization** — Checkpoints should only look for the `Player` physics layer to minimize the number of physics overlap calculations.
- **NEVER use standard lerp for ghost rotation** — Use `slerp()` or `Quaternion.slerp()` to avoid gimbal lock and ensure smooth rotation interpolation.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [time_trial_patterns.gd](../scripts/game_loop_time_trial_time_trial_patterns.gd)
10 Expert patterns: Microsecond timing, server-authoritative validation, rubber-banding AI, and frame-perfect input flushing.

### [time_trial_manager.gd](../scripts/game_loop_time_trial_time_trial_manager.gd)
The central clock. Validates checkpoint order and handles "Best Lap" logic.

### [ghost_recorder.gd](../scripts/game_loop_time_trial_ghost_recorder.gd)
Captures high-frequency transform data for playback.
