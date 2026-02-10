---
name: godot-adapt-3d-to-2d
description: "Expert patterns for simplifying 3D games to 2D including dimension reduction strategies, camera flattening, physics conversion, 3D-to-sprite art pipeline, and control simplification. Use when porting 3D to 2D, creating 2D versions for mobile, or prototyping. Trigger keywords: CharacterBody3D to CharacterBody2D, Camera3D to Camera2D, Vector3 to Vector2, flatten Z-axis, orthogonal projection, 3D to sprite conversion, performance optimization."
---

# Adapt: 3D to 2D

Expert guidance for simplifying 3D games into 2D (or 2.5D).

## NEVER Do

- **NEVER remove Z-axis without gameplay compensation** — Blindly flattening 3D to 2D removes spatial strategy. Add other depth mechanics (layers, jump height variations).
- **NEVER keep 3D collision shapes** — Use simpler 2D shapes (CapsuleShape2D, RectangleShape2D). 3D shapes don't convert automatically.
- **NEVER use orthographic Camera3D as "2D mode"** — Use actual Camera2D for proper 2D rendering pipeline and performance.
- **NEVER assume automatic performance gain** — Poorly optimized 2D (too many draw calls, large sprite sheets) can be slower than optimized 3D.
- **NEVER forget to adjust gravity** — 3D gravity is Vector3(0, -9.8, 0). 2D gravity is float (980 pixels/s²). Scale appropriately.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [ortho_simulation.gd](scripts/ortho_simulation.gd)
Simulates 3D Z-axis height in 2D top-down games. Handles vertical velocity, gravity, sprite offset, and shadow scaling.

### [projection_utils.gd](scripts/projection_utils.gd)
Projects 3D world positions to 2D screen space for nameplates, healthbars, and targeting. Handles behind-camera detection and distance-based scaling.

---

## Why Go from 3D to 2D?

| Reason | Benefit |
|--------|---------|
| **Mobile performance** | 5-10x faster on low-end devices |
| **Simpler art pipeline** | Sprites easier to create than 3D models |
| **Faster iteration** | 2D level design is quicker |
| **Accessibility** | Lower hardware requirements |
| **Clarity** | Reduce visual clutter for puzzle/strategy games |

---

## Dimension Reduction Strategies

### Strategy 1: True 2D (Remove Z-axis)

```gdscript
# Top-down or side-view
# Example: 3D isometric → 2D top-down

# Before (3D):
var velocity := Vector3(input.x, 0, input.y) * speed

# After (2D):
var velocity := Vector2(input.x, input.y) * speed

# Use case: Top-down shooters, RTS, turn-based strategy
```

### Strategy 2: 2.5D (Fake depth with layers)

```gdscript
# Keep visual depth perception without Z-axis gameplay
# Use ParallaxBackground for depth layers

# Scene structure:
# ParallaxBackground
#   ├─ ParallaxLayer (far mountains, scroll slow)
#   ├─ ParallaxLayer (mid buildings, scroll medium)
#   └─ ParallaxLayer (near trees, scroll fast)

# player.gd
extends CharacterBody2D

func _ready() -> void:
    var parallax := get_node("../ParallaxBackground")
    parallax.scroll_base_scale = Vector2(0.5, 0.5)  # Parallax strength
```

### Strategy 3: Fixed Perspective (Isometric Stay)

```gdscript
# Keep isometric/dimetric view but use 2D physics
# Use rotated sprites to simulate 3D angles

const ISO_ANGLE := deg_to_rad(-30)  # Isometric tilt

func world_to_iso(pos: Vector2) -> Vector2:
    return Vector2(
        pos.x - pos.y,
        (pos.x + pos.y) * 0.5
    )

func iso_to_world(iso_pos: Vector2) -> Vector2:
    return Vector2(
        (iso_pos.x + iso_pos.y * 2) * 0.5,
        (iso_pos.y * 2 - iso_pos.x) * 0.5
    )
```

---

## Node Conversion

### Physics Bodies

```gdscript
# CharacterBody3D → CharacterBody2D
extends CharacterBody3D  # Before

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8

func _physics_process(delta: float) -> void:
    velocity.y -= GRAVITY * delta
    var input := Input.get_vector("left", "right", "forward", "back")
    velocity.x = input.x * SPEED
    velocity.z = input.y * SPEED
    move_and_slide()

# ⬇️ Convert to:

extends CharacterBody2D  # After

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0  # Pixels per second squared

func _physics_process(delta: float) -> void:
    velocity.y += GRAVITY * delta
    var input := Input.get_vector("left", "right", "up", "down")
    velocity.x = input.x * SPEED
    # Note: No Z-axis. For platformer, use input.y for jump
    move_and_slide()
```

### Camera Conversion

```gdscript
# Camera3D → Camera2D
# Before: Third-person 3D camera
extends SpringArm3D

@onready var camera: Camera3D = $Camera3D

func _process(delta: float) -> void:
    spring_length = 10.0
    rotate_y(Input.get_axis("cam_left", "cam_right") * delta)

# ⬇️ Convert to:

extends Camera2D  # After

@onready var player: CharacterBody2D = $"../Player"

func _process(delta: float) -> void:
    global_position = player.global_position
    zoom = Vector2(2.0, 2.0)  # Adjust to taste
```

---

## Art Pipeline: 3D Models → Sprites

### Option 1: Render Sprites from 3D (Automation)

```gdscript
# Use Godot to render 3D model from fixed angles
# sprite_renderer.gd (tool script)
@tool
extends Node3D

@export var model_path: String = "res://models/character.glb"
@export var output_dir: String = "res://sprites/"
@export var angles: int = 8  # 8-directional sprites
@export var render: bool = false:
    set(value):
        if value:
            render_sprites()

func render_sprites() -> void:
    var model := load(model_path).instantiate()
    add_child(model)
    
    var camera := Camera3D.new()
    camera.position = Vector3(0, 2, 5)
    camera.look_at(Vector3.ZERO)
    add_child(camera)
    
    var viewport := SubViewport.new()
    viewport.size = Vector2i(256, 256)
    viewport.transparent_bg = true
    viewport.add_child(camera)
    add_child(viewport)
    
    for i in range(angles):
        model.rotation.y = (TAU / angles) * i
        
        await RenderingServer.frame_post_draw
        var img := viewport.get_texture().get_image()
        img.save_png("%s/sprite_%d.png" % [output_dir, i])
    
    model.queue_free()
    camera.queue_free()
    viewport.queue_free()
```

### Option 2: Manual Export (Blender)

```python
# Blender Python script (run in Blender)
import bpy
import math

angles = 8
output_dir = "/path/to/sprites/"
model = bpy.data.objects["Character"]

for i in range(angles):
    model.rotation_euler.z = (2 * math.pi / angles) * i
    bpy.ops.render.render(write_still=True)
    bpy.data.images['Render Result'].save_render(
        filepath=f"{output_dir}/sprite_{i}.png"
    )
```

### Option 3: Use Sprite3D as Reference

```gdscript
# Keep 3D model in editor, export  frame-by-frame
```

---

## Physics Adjustments

### Gravity Scaling

```gdscript
# 3D gravity (m/s²): 9.8
# 2D gravity (pixels/s²): Scale to pixel units

# If 1 meter = 100 pixels:
const GRAVITY_2D = 9.8 * 100  # = 980 pixels/s²

# Adjust jump velocity proportionally:
# 3D jump: 4.5 m/s
# 2D jump: -450 pixels/s
```

### Collision Simplification

```gdscript
# 3D: CapsuleShape3D (16 segments, expensive)
var shape_3d := CapsuleShape3D.new()
shape_3d.radius = 0.5
shape_3d.height = 2.0

# 2D: CapsuleShape2D (much simpler)
var shape_2d := CapsuleShape2D.new()
shape_2d.radius = 16  # pixels
shape_2d.height = 64
```

---

## Control Simplification

### 3D Free Movement → 2D Restricted

```gdscript
# 3D: Full 3D movement with camera-relative controls
var input_3d := Input.get_vector("left", "right", "forward", "back")
var camera_basis := camera.global_transform.basis
var direction := (camera_basis * Vector3(input_3d.x, 0, input_3d.y)).normalized()

# 2D: Simple 4-direction (or 8-direction with diagonals)
var input_2d := Input.get_vector("left", "right", "up", "down")
velocity = input_2d.normalized() * SPEED
```

---

## Performance Gains

### Expected Improvements

| Metric | 3D | 2D | Improvement |
|--------|----|----|-------------|
| Draw calls | 100 | 20 | 5x |
| GPU load | High | Low | 10x |
| Battery life (mobile) | 1 hour | 5 hours | 5x |
| RAM usage | 500MB | 100MB | 5x |

### Optimization Techniques

```gdscript
# 1. Use TileMapLayer instead of individual Sprite2D nodes
var tilemap := TileMapLayer.new()
tilemap.tile_set = load("res://tileset.tres")

# 2. Batch sprite rendering
# Use single large sprite sheet instead of individual textures

# 3. Reduce particle count
var godot-particles := GPUParticles2D.new()
godot-particles.amount = 50  # Down from 200 in 3D
```

---

## UI Adaptation

```gdscript
# Most 3D games already use 2D UI (CanvasLayer)
# No changes needed!

# Just verify UI scaling for new aspect ratios
get_viewport().size_changed.connect(_on_viewport_resized)

func _on_viewport_resized() -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    # Adjust UI anchors/margins
```

---

## Edge Cases

### Depth Sorting

```gdscript
# Problem: Overlapping sprites need sorting
# Solution: Use Y-sort or z_index

extends Sprite2D

func _ready() -> void:
    y_sort_enabled = true  # Auto-sort by Y position
    # Or set z_index manually:
    z_index = int(global_position.y)
```

### Lost Spatial Audio

```gdscript
# 3D spatial audio (AudioStreamPlayer3D) → 2D panning (AudioStreamPlayer2D)

var audio_2d := AudioStreamPlayer2D.new()
audio_2d.stream = load("res://sounds/footstep.ogg")
audio_2d.max_distance = 1000.0  # 2D range
audio_2d.attenuation = 2.0
add_child(audio_2d)
```

---

## Decision Tree: When to Simplify to 2D

| Factor | Keep 3D | Go 2D |
|--------|---------|-------|
| **Target platform** | Desktop, console | Mobile, web |
| **Art style** | Realistic, immersive | Stylized, retro |
| **Gameplay** | Requires 3D space | Works in 2D plane |
| **Performance** | Have GPU budget | Need 60 FPS on low-end |
| **Team skills** | 3D artists | 2D artists or pixel art |


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
