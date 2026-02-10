---
name: godot-2d-animation
description: "Expert patterns for 2D animation in Godot using AnimatedSprite2D and skeletal cutout rigs. Use when implementing sprite frame animations, procedural animation (squash/stretch), cutout bone hierarchies, or frame-perfect timing systems. Trigger keywords: AnimatedSprite2D, SpriteFrames, animation_finished, animation_looped, frame_changed, frame_progress, set_frame_and_progress, cutout animation, skeletal 2D, Bone2D, procedural animation, animation state machine, advance(0)."
---

# 2D Animation

Expert-level guidance for frame-based and skeletal 2D animation in Godot.

## NEVER Do

- **NEVER use `animation_finished` for looping animations** — The signal only fires on non-looping animations. Use `animation_looped` instead for loop detection.
- **NEVER call `play()` and expect instant state changes** — AnimatedSprite2D applies `play()` on the next process frame. Call `advance(0)` immediately after `play()` if you need synchronous property updates (e.g., when changing animation + flip_h simultaneously).
- **NEVER set `frame` directly when preserving animation progress** — Setting `frame` resets `frame_progress` to 0.0. Use `set_frame_and_progress(frame, progress)` to maintain smooth transitions when swapping animations mid-frame.
- **NEVER forget to cache `@onready var anim_sprite`** — The node lookup getter is surprisingly slow in hot paths like `_physics_process()`. Always use `@onready`.
- **NEVER mix AnimationPlayer tracks with code-driven AnimatedSprite2D** — Choose one animation authority per sprite. Mixing causes flickering and state conflicts.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [animation_sync.gd](scripts/animation_sync.gd)
Method track triggers for frame-perfect logic (SFX/VFX hitboxes), signal-driven async gameplay orchestration, and AnimationTree blend space management. Use when syncing gameplay events to animation frames.

### [animation_state_sync.gd](scripts/animation_state_sync.gd)
Frame-perfect state-driven animation with transition queueing - essential for responsive character animation.

### [shader_hook.gd](scripts/shader_hook.gd)
Animating ShaderMaterial uniforms via AnimationPlayer property tracks. Covers hit flash, dissolve effects, and instance uniforms for batched sprites. Use for visual feedback tied to animation states.

---

## AnimatedSprite2D Signals (Expert Usage)

### animation_looped vs animation_finished

```gdscript
extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    # ✅ Correct: Use animation_looped for repeating animations
    anim.animation_looped.connect(_on_loop)
    
    # ✅ Correct: Use animation_finished ONLY for one-shots
    anim.animation_finished.connect(_on_finished)
    
    anim.play("run")  # Looping animation

func _on_loop() -> void:
    # Fires every loop iteration
    emit_particle_effect("dust")

func _on_finished() -> void:
    # Only fires for non-looping animations
    anim.play("idle")
```

### frame_changed for Event Triggering

```gdscript
# Frame-perfect event system (attacks, footsteps, etc.)
extends AnimatedSprite2D

signal attack_hit
signal footstep

# Define event frames per animation
const EVENT_FRAMES := {
    "attack": {3: "attack_hit", 7: "attack_hit"},
    "run": {2: "footstep", 5: "footstep"}
}

func _ready() -> void:
    frame_changed.connect(_on_frame_changed)

func _on_frame_changed() -> void:
    var events := EVENT_FRAMES.get(animation, {})
    if frame in events:
        emit_signal(events[frame])
```

---

## Advanced Pattern: Animation State Sync

### Problem: play() Timing Glitch

When updating both animation and sprite properties (e.g., `flip_h` + animation change), `play()` doesn't apply until next frame, causing a 1-frame visual glitch.

```gdscript
# ❌ BAD: Glitches for 1 frame
func change_direction(dir: int) -> void:
    anim.flip_h = (dir < 0)
    anim.play("run")  # Applied NEXT frame
    # Result: 1 frame of wrong animation with correct flip

# ✅ GOOD: Force immediate sync
func change_direction(dir: int) -> void:
    anim.flip_h = (dir < 0)
    anim.play("run")
    anim.advance(0)  # Force immediate update
```

---

## set_frame_and_progress() for Smooth Transitions

Use when changing animations mid-animation without visual stutter:

```gdscript
# Example: Skin swapping without animation reset
func swap_skin(new_skin: String) -> void:
    var current_frame := anim.frame
    var current_progress := anim.frame_progress
    
    # Load new SpriteFrames resource
    anim.sprite_frames = load("res://skins/%s.tres" % new_skin)
    
    # ✅ Preserve exact animation state
    anim.play(anim.animation)  # Re-apply animation
    anim.set_frame_and_progress(current_frame, current_progress)
    # Result: Seamless skin swap mid-animation
```

---

## Decision Tree: AnimatedSprite2D vs AnimationPlayer

| Scenario | Use |
|----------|-----|
| Simple frame-based sprite swapping | AnimatedSprite2D |
| Need to animate other properties (position, scale, rotation) | AnimationPlayer |
| Character with swappable skins/palettes | AnimatedSprite2D (swap SpriteFrames) |
| Cutout animation with 10+ bones | AnimationPlayer (cleaner track management) |
| Need to blend/crossfade animations | AnimationPlayer (AnimationTree support) |
| Pixel-perfect retro game | AnimatedSprite2D (simpler frame control) |

---

## Expert Pattern: Procedural Squash & Stretch

```gdscript
# Physics-driven squash/stretch for game feel
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
var _base_scale := Vector2.ONE

func _physics_process(delta: float) -> void:
    var prev_velocity := velocity
    move_and_slide()
    
    # Squash on landing
    if not is_on_floor() and is_on_floor():
        var impact_strength := clamp(abs(prev_velocity.y) / 800.0, 0.0, 1.0)
        _squash_and_stretch(Vector2(1.0 + impact_strength * 0.3, 1.0 - impact_strength * 0.3))
    
    # Stretch during jump
    elif velocity.y < -200:
        sprite.scale = _base_scale.lerp(Vector2(0.9, 1.1), delta * 5.0)
    else:
        sprite.scale = sprite.scale.lerp(_base_scale, delta * 10.0)

func _squash_and_stretch(target_scale: Vector2) -> void:
    var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(sprite, "scale", target_scale, 0.08)
    tween.tween_property(sprite, "scale", _base_scale, 0.12)
```

---

## Cutout Animation (Bone2D Skeleton)

For complex skeletal animation, use Bone2D instead of manual Sprite2D parenting:

### Skeleton Setup

```
Player (Node2D)
  └─ Skeleton2D
      ├─ Bone2D (Root - Torso)
      │   ├─ Sprite2D (Body)
      │   └─ Bone2D (Head)
      │       └─ Sprite2D (Head)
      ├─ Bone2D (ArmLeft)
      │   └─ Sprite2D (Arm)
      └─ Bone2D (ArmRight)
          └─ Sprite2D (Arm)
```

### AnimationPlayer Tracks

```gdscript
# Key bone rotations in AnimationPlayer
# Tracks:
# - "Skeleton2D/Bone2D:rotation"
# - "Skeleton2D/Bone2D/Bone2D2:rotation" (head)
# - "Skeleton2D/Bone2D3:rotation" (arm left)
```

**Why Bone2D over manual parenting?**
- Forward Kinematics (FK) and Inverse Kinematics (IK) support
- Easier to rig and weight paint
- Better integration with animation retargeting

---

## Performance: SpriteFrames Optimization

```gdscript
# ✅ GOOD: Share SpriteFrames resource across instances
const SHARED_FRAMES := preload("res://characters/player_frames.tres")

func _ready() -> void:
    anim_sprite.sprite_frames = SHARED_FRAMES
    # All player instances share same resource in memory

# ❌ BAD: Each instance loads separately
func _ready() -> void:
    anim_sprite.sprite_frames = load("res://characters/player_frames.tres")
    # Duplicates resource in memory per instance
```

---

## Edge Case: Pixel Art Centering

```gdscript
# Pixel art textures can appear blurry when centered between pixels
# Solution 1: Disable centering
anim_sprite.centered = false
anim_sprite.offset = Vector2.ZERO

# Solution 2: Enable global pixel snapping (Project Settings)
# rendering/2d/snap/snap_2d_vertices_to_pixel = true
# rendering/2d/snap/snap_2d_transforms_to_pixel = true
```

### SpriteFrames Texture Filtering

```gdscript
# Problem: SpriteFrames uses bilinear filtering (blurry for pixel art)
# Solution: In Import tab for each texture:
# - Filter: Nearest (for pixel art)
# - Mipmaps: Off (prevents blending at distance)

# Or set globally in Project Settings:
# rendering/textures/canvas_textures/default_texture_filter = Nearest
```


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
