> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Tweening**. Accessed via Godot Master.

# Tweening

Tween property animation, easing curves, chaining, and lifecycle management define smooth programmatic motion.

## Available Scripts

### [juice_manager.gd](../scripts/tweening_juice_manager.gd)
Expert tween-based juice system with reusable effect presets (bounce, shake, pulse, etc.).


## NEVER Do in Tweening

- **NEVER create tweens without killing previous** — Avoid overlapping and conflicting animations on the same property. Store your tween in a variable and call `kill()` before starting a new one.
- **NEVER create tweens every frame in `_process`** — Tweens are for interpolated changes over time, not for per-frame physics or logic that should be handled directly.
- **NEVER forget `set_parallel(true)` for simultaneous animations** — Tweens are sequential by default.
- **NEVER use linear interpolation for UI** — Linear feels robotic. Use `EASE_OUT` with `TRANS_QUAD` or `TRANS_CUBIC` for a more natural feel.

---

## Basic Tween Usage
```gdscript
var tween := create_tween()
tween.tween_property($Sprite, "position", Vector2(100, 100), 1.0)
```

## Chaining and Sequences
```gdscript
var tween := create_tween()
tween.tween_property($Sprite, "modulate:a", 0.0, 0.5) # Fade out
tween.tween_interval(0.2)                             # Pause
tween.tween_property($Sprite, "modulate:a", 1.0, 0.5) # Fade in
```

## Parallel Tweens
```gdscript
var tween := create_tween()
tween.set_parallel(true)
tween.tween_property($Sprite, "scale", Vector2(2, 2), 1.0)
tween.tween_property($Sprite, "modulate", Color.RED, 1.0)
```

## Easing and Transitions
```gdscript
var tween := create_tween()
tween.set_ease(Tween.EASE_OUT)
tween.set_trans(Tween.TRANS_ELASTIC)
tween.tween_property($Sprite, "position:y", 100.0, 1.5)
```

## Common Combinations
- **Bouncy UI**: `EASE_OUT` + `TRANS_BOUNCE`
- **Smooth Accelerate**: `EASE_IN` + `TRANS_QUAD`
- **Natural UI Snap**: `EASE_OUT` + `TRANS_EXPO`

## Method Tweening
For non-property changes, use `tween_method` to call a function with an interpolated value:
```gdscript
tween.tween_method(func(val): label.text = str(val), 0, 100, 1.0)
```

## Reference
- [Godot Docs: Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html)
