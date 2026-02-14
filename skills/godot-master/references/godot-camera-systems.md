> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Camera Systems**. Accessed via Godot Master.

# Camera Systems

Expert guidance for creating smooth, responsive cameras in 2D and 3D games with focus on cinematic control and visual feedback.

## Available Scripts

### [camera_follow_2d.gd](../scripts/godot-camera-systems_camera_follow_2d.gd)
Smooth camera following with look-ahead prediction, deadzones, and boundary limits.

### [camera_shake_trauma.gd](../scripts/godot-camera-systems_camera_shake_trauma.gd)
Trauma-based camera shake using Perlin noise/FastNoiseLite. Industry-standard implementation for polished screen shake.

### [phantom_decoupling.gd](../scripts/godot-camera-systems_phantom_decoupling.gd)
Phantom camera pattern: separates the camera node from the tracking logic for cinematic offsets and smooth area bounds.


## NEVER Do

- **NEVER use `global_position = target.global_position` every frame** — Instant position matching causes jittery movement. Use `lerp()`, `move_toward()`, or built-in smoothing.
- **NEVER forget `limit_smoothed = true` for Camera2D** — Hard limits cause jarring stops at screen edges. Smoothing ensures a graceful deceleration.
- **NEVER use `offset` for permanent camera positioning** — Reserve `offset` for transient effects like shake or sway; use `position` for static alignment.
- **NEVER enable multiple Camera2D nodes simultaneously** — Ensure only one camera is `enabled = true` at any time to avoid rendering conflicts.
- **NEVER use SpringArm3D without a collision mask** — Without a mask, the arm will clip through walls and objects.

---

## 2D Smoothing and Limits
Leverage built-in smoothing for a quick, polished result:
```gdscript
position_smoothing_enabled = true
position_smoothing_speed = 5.0
limit_smoothed = true
```

## Screen Shake (Trauma System)
The "Trauma" system uses a 0.0 to 1.0 trauma value that decays over time. The actual shake amount is `trauma * trauma` (or cubed) to provide a non-linear feel that is more satisfying.

## Look-Ahead (Lead) Pattern
Calculate target velocity and add a lead offset to the camera position so players can see further in the direction they are moving.

## 3D Spatial Patterns

### Third-Person Follow
Use a `SpringArm3D` and `Camera3D` to handle obstructions automatically.
```gdscript
# Scene structure
# SpringArm3D (collision enabled)
#   └─ Camera3D
```

### First-Person View
Lock the mouse and rotate the parent node (yaw) and camera (pitch) independently to avoid gimbal lock.

## Reference
- [Godot Docs: Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html)
- [Godot Docs: Camera3D](https://docs.godotengine.org/en/stable/classes/class_camera3d.html)
