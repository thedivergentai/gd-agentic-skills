---
name: godot-tweening
description: "Expert blueprint for programmatic animation using Tween for smooth property transitions, UI effects, camera movements, and juice. Covers easing functions, parallel tweens, chaining, and lifecycle management. Use when implementing UI animations OR procedural movement. Keywords Tween, easing, interpolation, EASE_IN_OUT, TRANS_CUBIC, tween_property, tween_callback."
---

# Tweening

Tween property animation, easing curves, chaining, and lifecycle management define smooth programmatic motion.

## Available Scripts

### [juice_manager.gd](scripts/juice_manager.gd)
Expert tween-based juice system with reusable effect presets (bounce, shake, pulse, etc.).

## NEVER Do in Tweening

- **NEVER create tweens without killing previous** — Spam click button, create 100 tweens? Memory leak + conflicting animations. ALWAYS `if tween: tween.kill()` before creating new.
- **NEVER tween in _process without create_tween()** — `create_tween()` every frame? 60 tweens/second × 60 frames = 3600 tween objects. Create ONCE, reuse OR kill old.
- **NEVER forget to set_parallel for simultaneous** — Chain `tween_property()` expecting simultaneous? Sequential by default. Use `tween.set_parallel(true)` first.
- **NEVER use 0-duration tweens for instant changes** — `tween_property(x, 0.0)` for teleport? Overhead of tween system. Just set property: `sprite.position = target`.
- **NEVER skip finished signal for cleanup** — Tween completes, node still references it? Memory held. Connect `tween.finished` for cleanup OR null reference.
- **NEVER use linear interpolation for UI** — `TRANS_LINEAR` for button hover? Robotic feel. Use `EASE_OUT + TRANS_QUAD` OR `EASE_IN_OUT + TRANS_CUBIC` for organic motion.

---

```gdscript
extends Sprite2D

func _ready() -> void:
    # Create tween
    var tween := create_tween()
    
    # Animate position over 2 seconds
    tween.tween_property(self, "position", Vector2(100, 100), 2.0)
```

## Tween Methods

### Property Animation

```gdscript
# Tween single property
var tween := create_tween()
tween.tween_property($Sprite, "modulate:a", 0.0, 1.0)  # Fade out

# Chain multiple tweens
tween.tween_property($Sprite, "position:x", 200, 1.0)
tween.tween_property($Sprite, "position:y", 100, 0.5)
```

### Callbacks

```gdscript
var tween := create_tween()
tween.tween_property($Sprite, "position", Vector2(100, 0), 1.0)
tween.tween_callback(func(): print("Animation done!"))
tween.tween_callback(queue_free)  # Delete after animation
```

### Intervals

```gdscript
var tween := create_tween()
tween.tween_property($Label, "modulate:a", 0.0, 0.5)
tween.tween_interval(1.0)  # Wait 1 second
tween.tween_property($Label, "modulate:a", 1.0, 0.5)
```

## Easing Functions

```gdscript
var tween := create_tween()
tween.set_ease(Tween.EASE_IN_OUT)  # Smooth start and end
tween.set_trans(Tween.TRANS_CUBIC)  # Cubic curve
tween.tween_property($Sprite, "position:x", 200, 1.0)
```

**Common Combinations:**
- `EASE_IN + TRANS_QUAD`: Accelerating
- `EASE_OUT + TRANS_QUAD`: Decelerating
- `EASE_IN_OUT + TRANS_CUBIC`: Smooth S-curve
- `EASE_OUT + TRANS_BOUNCE`: Bouncy effect

## Advanced Patterns

### Looping Animation

```gdscript
var tween := create_tween()
tween.set_loops()  # Infinite loop
tween.tween_property($Sprite, "rotation", TAU, 2.0)
```

### Parallel Tweens

```gdscript
var tween := create_tween()
tween.set_parallel(true)

# Both happen simultaneously
tween.tween_property($Sprite, "position", Vector2(100, 100), 1.0)
tween.tween_property($Sprite, "scale", Vector2(2, 2), 1.0)
```

### UI Button Hover Effect

```gdscript
extends Button

func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)

func _on_mouse_exited() -> void:
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2.ONE, 0.2)
```

### Number Counter

```gdscript
extends Label

func count_to(target: int, duration: float = 1.0) -> void:
    var current := int(text)
    var tween := create_tween()
    
    tween.tween_method(
        func(value: int): text = str(value),
        current,
        target,
        duration
    )
```

### Camera Smooth Follow

```gdscript
extends Camera2D

@export var follow_speed := 5.0
var target: Node2D

func _process(delta: float) -> void:
    if target:
        var tween := create_tween()
        tween.tween_property(
            self,
            "global_position",
            target.global_position,
            1.0 / follow_speed
        )
```

## Best Practices

### 1. Kill Previous Tweens

```gdscript
var current_tween: Tween = null

func animate_to(pos: Vector2) -> void:
    if current_tween:
        current_tween.kill()  # Stop previous animation
    
    current_tween = create_tween()
    current_tween.tween_property(self, "position", pos, 1.0)
```

### 2. Use Signals for Completion

```gdscript
var tween := create_tween()
tween.tween_property($Sprite, "position", Vector2(100, 0), 1.0)
tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
    print("Animation complete!")
```

### 3. Chaining for Sequences

```gdscript
var tween := create_tween()

# Fade out
tween.tween_property($Sprite, "modulate:a", 0.0, 0.5)
# Move while invisible
tween.tween_property($Sprite, "position", Vector2(200, 0), 0.0)
# Fade in at new position
tween.tween_property($Sprite, "modulate:a", 1.0, 0.5)
```

## Common Gotchas

**Issue**: Tween stops when node is removed
```gdscript
# Solution: Bind tween to SceneTree
var tween := get_tree().create_tween()
tween.tween_property($Sprite, "position", Vector2(100, 0), 1.0)
```

**Issue**: Multiple conflicting tweens
```gdscript
# Solution: Use single tween or kill previous
# Always store reference to kill old tween
```

## Reference
- [Godot Docs: Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
