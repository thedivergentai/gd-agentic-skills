---
name: godot-camera-systems
description: "Expert patterns for 2D/3D camera control including smooth following (lerp, position_smoothing), camera shake (trauma system), screen shake with frequency parameters, deadzone/drag for platformers, look-ahead prediction, and camera transitions. Use for player cameras, cinematic sequences, or multi-camera systems. Trigger keywords: Camera2D, Camera3D, SpringArm3D, position_smoothing, camera_shake, trauma_system, look_ahead, drag_margin, camera_limits, camera_transition."
---

# Camera Systems

Expert guidance for creating smooth, responsive cameras in 2D and 3D games.

## NEVER Do

- **NEVER use `global_position = target.global_position` every frame** — Instant position matching causes jittery movement. Use `lerp()` or `position_smoothing_enabled = true`.
- **NEVER forget `limit_smoothed = true` for Camera2D** — Hard limits cause sudden stops at edges. Smoothing prevents jarring halts.
- **NEVER use offset for permanent camera positioning** — `offset` is for shake/sway effects only. Use `position` for permanent camera placement.
- **NEVER enable multiple Camera2D nodes simultaneously** — Only one camera can be active. Others must have `enabled = false`.
- **NEVER use SpringArm3D without collision mask** — SpringArm clips through walls if `collision_mask` is empty. Set to world layer

---

## Available Scripts

> **MANDATORY**: Read before implementing camera behaviors.

### [camera_follow_2d.gd](scripts/camera_follow_2d.gd)
Smooth camera following with look-ahead prediction, deadzones, and boundary limits.

### [camera_shake_trauma.gd](scripts/camera_shake_trauma.gd)
Trauma-based camera shake using Perlin noise - industry-standard screenshake implementation. Uses FastNoiseLite for smooth camera shake (squared trauma for feel) with automatic decay.

### [phantom_decoupling.gd](scripts/phantom_decoupling.gd)
Phantom camera pattern: separates "where we look" from "what we follow". Camera follows phantom node, enabling cinematic offsets and area bounds.

---

## Camera2D Basics

```gdscript
extends Camera2D

@export var target: Node2D
@export var follow_speed := 5.0

func _process(delta: float) -> void:
    if target:
        global_position = global_position.lerp(
            target.global_position,
            follow_speed * delta
        )
```

## Position Smoothing

```gdscript
extends Camera2D

func _ready() -> void:
    # Built-in smoothing
    position_smoothing_enabled = true
    position_smoothing_speed = 5.0
```

## Camera Limits

```gdscript
extends Camera2D

func _ready() -> void:
    # Constrain camera to level bounds
    limit_left = 0
    limit_top = 0
    limit_right = 1920
    limit_bottom = 1080
    
    # Smooth against limits
    limit_smoothed = true
```

## Camera Shake

```gdscript
extends Camera2D

var shake_amount := 0.0
var shake_decay := 5.0

func _process(delta: float) -> void:
    if shake_amount > 0:
        shake_amount = max(shake_amount - shake_decay * delta, 0)
        offset = Vector2(
            randf_range(-shake_amount, shake_amount),
            randf_range(-shake_amount, shake_amount)
        )
    else:
        offset = Vector2.ZERO

func shake(intensity: float) -> void:
    shake_amount = intensity

# Usage:
$Camera2D.shake(10.0)  # Screen shake on explosion
```

## Zoom Controls

```gdscript
extends Camera2D

@export var zoom_speed := 0.1
@export var min_zoom := 0.5
@export var max_zoom := 2.0

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            zoom_in()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            zoom_out()

func zoom_in() -> void:
    zoom = zoom.move_toward(
        Vector2.ONE * max_zoom,
        zoom_speed
    )

func zoom_out() -> void:
    zoom = zoom.move_toward(
        Vector2.ONE * min_zoom,
        zoom_speed
    )
```

## Look-Ahead Camera

```gdscript
extends Camera2D

@export var look_ahead_distance := 50.0
@export var target: CharacterBody2D

func _process(delta: float) -> void:
    if target:
        var look_ahead := target.velocity.normalized() * look_ahead_distance
        global_position = target.global_position + look_ahead
```

## Split-Screen (Multiple Cameras)

```gdscript
# Player 1 Camera
@onready var cam1: Camera2D = $Player1/Camera2D

# Player 2 Camera
@onready var cam2: Camera2D = $Player2/Camera2D

func _ready() -> void:
    # Split viewport
    cam1.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
    cam2.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
```

## Camera3D Patterns

### Third-Person Camera

```gdscript
extends Camera3D

@export var target: Node3D
@export var distance := 5.0
@export var height := 2.0
@export var rotation_speed := 3.0

var rotation_angle := 0.0

func _process(delta: float) -> void:
    if not target:
        return
    
    # Rotate around target
    rotation_angle += Input.get_axis("camera_left", "camera_right") * rotation_speed * delta
    
    # Calculate position
    var offset := Vector3(
        sin(rotation_angle) * distance,
        height,
        cos(rotation_angle) * distance
    )
    
    global_position = target.global_position + offset
    look_at(target.global_position, Vector3.UP)
```

### First-Person Camera

```gdscript
extends Camera3D

@export var mouse_sensitivity := 0.002
@export var max_pitch := deg_to_rad(80)

var pitch := 0.0

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        # Yaw (horizontal)
        get_parent().rotate_y(-event.relative.x * mouse_sensitivity)
        
        # Pitch (vertical)
        pitch -= event.relative.y * mouse_sensitivity
        pitch = clamp(pitch, -max_pitch, max_pitch)
        rotation.x = pitch
```

## Camera Transitions

```gdscript
# Smooth camera position change
func move_to_position(target_pos: Vector2, duration: float = 1.0) -> void:
    var tween := create_tween()
    tween.tween_property(self, "global_position", target_pos, duration)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.set_trans(Tween.TRANS_CUBIC)
```

## Cinematic Cameras

```gdscript
# Camera path following
extends Path2D

@onready var path_follow: PathFollow2D = $PathFollow2D
@onready var camera: Camera2D = $PathFollow2D/Camera2D

func play_cutscene(duration: float) -> void:
    var tween := create_tween()
    tween.tween_property(path_follow, "progress_ratio", 1.0, duration)
    await tween.finished
```

## Best Practices

### 1. One Active Camera

```gdscript
# Only one Camera2D should be enabled at a time
# Others should have enabled = false
```

### 2. Parent Camera to Player

```gdscript
# Scene structure:
# Player (CharacterBody2D)
#   └─ Camera2D
```

### 3. Use Anchors for UI

```gdscript
# Camera doesn't affect UI positioned with anchors
# UI stays in screen space
```

### 4. Deadzone for Platformers

```gdscript
extends Camera2D

func _ready() -> void:
    drag_horizontal_enabled = true
    drag_vertical_enabled = true
    drag_left_margin = 0.3
    drag_right_margin = 0.3
```

## Reference
- [Godot Docs: Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html)
- [Godot Docs: Camera3D](https://docs.godotengine.org/en/stable/classes/class_camera3d.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
