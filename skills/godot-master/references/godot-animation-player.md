> [!NOTE]
> **Resource Context**: This module provides expert patterns for **AnimationPlayer**. Accessed via Godot Master.

# AnimationPlayer

Expert guidance for Godot's timeline-based keyframe animation system.

## Available Scripts

### [audio_sync_tracks.gd](../scripts/godot-animation-player_audio_sync_tracks.gd)
Sub-frame audio synchronization via Animation.TYPE_AUDIO tracks. Footstep setup with automatic blend handling for cross-fades.

### [programmatic_anim.gd](../scripts/godot-animation-player_programmatic_anim.gd)
Procedural animation generation: creates Animation resources via code with keyframes, easing, and transition curves.


## NEVER Do

- **NEVER forget RESET tracks** — Without a RESET track, animated properties don't restore to initial values.
- **NEVER use Animation.CALL_MODE_CONTINUOUS for function calls** — This calls the method EVERY frame. Use `CALL_MODE_DISCRETE`.
- **NEVER animate resource properties directly** — Animate variables that hold resources instead to avoid file bloat.
- **NEVER use animation_finished for looping animations** — Signal doesn't fire. Use `animation_looped` if available or manual state checks.

---

## Track Types

- **Value Tracks**: Animate properties like position, scale, color, or custom variables.
- **Method Tracks**: Call functions on any node at specific timestamps.
- **Audio Tracks**: Synchronize sound effects with frame-perfect precision.
- **Bezier Tracks**: Use custom cubic curves for smooth, highly controlled interpolation.

## Root Motion Extraction
For characters with walk/run animations that include actual translation in the rig, use Root Motion to extract that movement and apply it to the `CharacterBody3D` or `CharacterBody2D` root node.

```gdscript
func _physics_process(delta: float) -> void:
    var root_motion_pos := anim_player.get_root_motion_position()
    velocity = root_motion_pos / delta
    move_and_slide()
```

## Animation Sequences
- **Queueing**: Use `anim.queue("next_animation")` to chain multiple animations.
- **Blending**: Use `play()` with the `custom_blend` parameter for smooth crossfades between states.

## RESET Track Pattern
Create a "RESET" animation that contains the default values for every property animated in other clips. Enable "Reset on Save" in settings to ensure the scene starts in a clean state.

## Reference
- [Godot Docs: AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html)
- [Godot Docs: Root Motion](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html#root-motion)
