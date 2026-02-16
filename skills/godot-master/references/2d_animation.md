> [!NOTE]
> **Resource Context**: This module provides expert patterns for **2D Animation**. Accessed via Godot Master.

# 2D Animation

Expert-level guidance for frame-based and skeletal 2D animation in Godot.

## Available Scripts

### [animation_sync.gd](../scripts/2d_animation_animation_sync.gd)
Method track triggers for frame-perfect logic, signal-driven async gameplay orchestration, and AnimationTree blend space management.

### [animation_state_sync.gd](../scripts/2d_animation_animation_state_sync.gd)
Frame-perfect state-driven animation with transition queueing - essential for responsive character animation.

### [shader_hook.gd](../scripts/2d_animation_shader_hook.gd)
Animating ShaderMaterial uniforms via AnimationPlayer property tracks. Covers hit flash and dissolve effects.


## NEVER Do

- **NEVER use `animation_finished` for looping animations** — Use `animation_looped` instead.
- **NEVER call `play()` and expect instant state changes** — Call `advance(0)` immediately after `play()` for synchronous property updates.
- **NEVER set `frame` directly when preserving animation progress** — Use `set_frame_and_progress(frame, progress)` to maintain smooth transitions.
- **NEVER mix AnimationPlayer tracks with code-driven AnimatedSprite2D** — Choose one authority per sprite to avoid state conflicts.

---

## AnimatedSprite2D Patterns

### Sync Animation & Visual State
```gdscript
func change_direction(dir: int) -> void:
    anim.flip_h = (dir < 0)
    anim.play("run")
    anim.advance(0)  # Force immediate update to prevent 1-frame glitches
```

### Seamless Skin Swapping
```gdscript
func swap_skin(new_skin_resource: SpriteFrames) -> void:
    var current_frame := anim.frame
    var current_progress := anim.frame_progress
    anim.sprite_frames = new_skin_resource
    anim.play(anim.animation)
    anim.set_frame_and_progress(current_frame, current_progress)
```

## Decision Tree: AnimatedSprite2D vs AnimationPlayer

| Scenario | Use |
|----------|-----|
| Simple frame-based sprite swapping | AnimatedSprite2D |
| Animate position, scale, rotation, shaders | AnimationPlayer |
| Character with swappable skins/palettes | AnimatedSprite2D |
| Complex skeletal cutout animation | AnimationPlayer |

## Procedural Squash & Stretch
Use Tweens to manipulate the `scale` property of a sprite during landings or jumps to improve "game feel" without requiring individual animation frames for every squash state.

## Reference
- [Godot Docs: AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html)
- [Godot Docs: Bone2D](https://docs.godotengine.org/en/stable/classes/class_bone2d.html)
