---
name: godot-adapt-2d-to-3d
description: "Expert patterns for migrating 2D games to 3D including node type conversions, camera systems (third-person, first-person, orbit), physics layer migration, sprite-to-model art pipeline, and control scheme adaptations. Use when porting 2D projects to 3D or adding 3D elements. Trigger keywords: CharacterBody2D to CharacterBody3D, Area2D to Area3D, Camera2D to Camera3D, Vector2 to Vector3, collision_layer migration, sprite to MeshInstance3D, 2D to 3D conversion."
---

# Adapt: 2D to 3D

Expert guidance for migrating 2D games into the third dimension.

## NEVER Do

- **NEVER directly replace Vector2 with Vector3(x, y, 0)** — This creates a "flat 3D" game with no depth gameplay. Add Z-axis movement or camera rotation to justify 3D.
- **NEVER keep 2D collision layers** — 2D and 3D physics use separate layer systems. You must reconfigure collision_layer/collision_mask for 3D nodes.
- **NEVER forget to add lighting** — 3D without lights is pitch black (unless using unlit materials). Add at least one DirectionalLight3D.
- **NEVER use Camera2D follow logic in 3D** — Camera3D needs spring arm or look-at logic. Direct position copying causes clipping and disorientation.
- **NEVER assume same performance** — 3D is 5-10x more demanding. Budget for lower draw calls, smaller viewport resolution on mobile.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [sprite_plane.gd](scripts/sprite_plane.gd)
Sprite3D billboard configuration and world-to-screen projection for placing 2D UI over 3D objects. Handles behind-camera detection.

### [vector_mapping.gd](scripts/vector_mapping.gd)
Static utility for 2D→3D vector translation. The Y-to-Z rule: 2D Y (down) maps to 3D Z (forward). Essential for movement code.

---

## Node Conversion Matrix

| 2D Node | 3D Equivalent | Notes |
|---------|---------------|-------|
| CharacterBody2D | CharacterBody3D | Add Z-axis movement, rotate with mouse |
| RigidBody2D | RigidBody3D | Gravity now Vector3(0, -9.8, 0) |
| StaticBody2D | StaticBody3D | Collision shapes use Shape3D |
| Area2D | Area3D | Triggers work the same way |
| Sprite2D | MeshInstance3D + QuadMesh | Or use Sprite3D (billboarded) |
| AnimatedSprite2D | AnimatedSprite3D | Billboard mode available |
| TileMapLayer | GridMap | Requires MeshLibrary creation |
| Camera2D | Camera3D | Requires repositioning logic |
| CollisionShape2D | CollisionShape3D | BoxShape2D → BoxShape3D, etc. |
| RayCast2D | RayCast3D | target_position is now Vector3 |

---

## Migration Steps

### Step 1: Physics Layer Reconfiguration

```gdscript
# 2D collision layers are SEPARATE from 3D
# You must reconfigure in Project Settings → Layer Names → 3D Physics

# Before (2D):
# Layer 1: Player
# Layer 2: Enemies
# Layer 3: World

# After (3D) - same names, but different system
# In code, update all collision layer references:

# 2D version:
# collision_layer = 0b0001

# 3D version (same logic, different node):
var character_3d := CharacterBody3D.new()
character_3d.collision_layer = 0b0001  # Layer 1: Player
character_3d.collision_mask = 0b0110   # Detect Enemies + World
```

### Step 2: Camera Conversion

```gdscript
# ❌ BAD: Direct 2D follow logic
extends Camera3D

@onready var player: Node3D = $"../Player"

func _process(delta: float) -> void:
    global_position = player.global_position  # Clipping, disorienting!

# ✅ GOOD: Third-person camera with SpringArm3D
# Scene structure:
# Player (CharacterBody3D)
#   └─ SpringArm3D
#       └─ Camera3D

# player.gd
extends CharacterBody3D

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

func _ready() -> void:
    spring_arm.spring_length = 10.0  # Distance from player
    spring_arm.position = Vector3(0, 2, 0)  # Above player

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        spring_arm.rotate_y(-event.relative.x * 0.005)  # Horizontal rotation
        spring_arm.rotate_object_local(Vector3.RIGHT, -event.relative.y * 0.005)  # Vertical
        
        # Clamp vertical rotation
        spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/3, PI/6)
```

### Step 3: Movement Conversion

```gdscript
# 2D platformer movement
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta
    
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
    
    var direction := Input.get_axis("left", "right")
    velocity.x = direction * SPEED
    
    move_and_slide()

# ✅ 3D equivalent (third-person platformer)
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8

@onready var spring_arm: SpringArm3D = $SpringArm3D

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
    
    # Movement relative to camera direction
    var input_dir := Input.get_vector("left", "right", "forward", "back")
    var camera_basis := spring_arm.global_transform.basis
    var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
        
        # Rotate player to face movement direction
        rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), 0.1)
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)
    
    move_and_slide()
```

---

## Art Pipeline: Sprites → 3D Models

### Option 1: Billboard Sprites (2.5D)

```gdscript
# Use Sprite3D for quick conversion
extends Sprite3D

func _ready() -> void:
    texture = load("res://sprites/character.png")
    billboard = BaseMaterial3D.BILLBOARD_ENABLED  # Always face camera
    pixel_size = 0.01  # Scale sprite in 3D space
```

### Option 2: Quad Meshes (Floating Sprites)

```gdscript
# Create textured quads
var mesh_instance := MeshInstance3D.new()
var quad := QuadMesh.new()
quad.size = Vector2(1, 1)
mesh_instance.mesh = quad

var material := StandardMaterial3D.new()
material.albedo_texture = load("res://sprites/character.png")
material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
material.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show both sides
mesh_instance.material_override = material
```

### Option 3: Full 3D Models (Blender/Asset Library)

```gdscript
# Import .glb, .fbx models
var character := load("res://models/character.glb").instantiate()
add_child(character)

# Access animations
var anim_player := character.get_node("AnimationPlayer")
anim_player.play("idle")
```

---

## Lighting Considerations

### Minimum Lighting Setup

```gdscript
# Add to main scene
var sun := DirectionalLight3D.new()
sun.rotation_degrees = Vector3(-45, 30, 0)
sun.light_energy = 1.0
sun.shadow_enabled = true
add_child(sun)

# Ambient light
var env := WorldEnvironment.new()
var environment := Environment.new()
environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
environment.ambient_light_color = Color(0.3, 0.3, 0.4)  # Subtle blue
environment.ambient_light_energy = 0.5
env.environment = environment
add_child(env)
```

---

## UI Adaptation

```gdscript
# ✅ GOOD: Keep 2D UI overlay
# Scene structure:
# Main (Node3D)
#   ├─ WorldEnvironment
#   ├─ DirectionalLight3D
#   ├─ Player (CharacterBody3D)
#   └─ CanvasLayer  # 2D UI on top of 3D world
#       └─ Control (HUD)

# UI remains 2D (Control nodes, Sprite2D for HUD elements)
```

---

## Performance Budgeting

### 2D vs 3D Performance

| Metric | 2D Budget | 3D Budget | Notes |
|--------|-----------|-----------|-------|
| Draw calls | 100-200 | 50-100 | Use fewer meshes |
| Vertices | Unlimited | 100K-500K | LOD important |
| Lights | N/A | 3-5 shadowed | Expensive |
| Transparent objects | Many | <10 | Sorting overhead |
| Particle systems | Many | 2-3 max | GPU godot-particles only |

### Optimization Checklist

```gdscript
# 1. Use LOD for distant objects
var mesh_instance := MeshInstance3D.new()
mesh_instance.lod_bias = 1.0  # Lower detail sooner

# 2. Occlusion culling
# Use OccluderInstance3D for large walls/buildings

# 3. Reduce shadow distance
var sun := DirectionalLight3D.new()
sun.directional_shadow_max_distance = 50.0  # Don't render far shadows

# 4. Use unlit materials for distant objects
var material := StandardMaterial3D.new()
material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
```

---

## Input Scheme Changes

### 2D → 3D Input Mapping

```gdscript
# 2D: left/right for horizontal movement
Input.get_axis("left", "right")

# 3D: Add forward/back, use get_vector()
var input := Input.get_vector("left", "right", "forward", "back")
# Returns Vector2(horizontal, vertical) for 3D movement

# Configure in Project Settings → Input Map:
# forward: W, Up Arrow
# back: S, Down Arrow
# left: A, Left Arrow
# right: D, Right Arrow

# Mouse look (lock cursor)
func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_camera(event.relative)
```

---

## Edge Cases

### Physics Not Working

```gdscript
# Problem: Forgot to set collision layers for 3D
# Solution: Reconfigure layers

var body := CharacterBody3D.new()
body.collision_layer = 0b0001  # What AM I?
body.collision_mask = 0b0110   # What do I DETECT?
```

### Camera Clipping Through Walls

```gdscript
# SpringArm3D automatically pulls camera forward when obstructed
spring_arm.spring_length = 10.0
spring_arm.collision_mask = 0b0100  # Layer 3: World
```

### Player Falling Through Floor

```gdscript
# Problem: StaticBody3D floor has no CollisionShape3D
# Solution: Add collision

var floor_collision := CollisionShape3D.new()
var box_shape := BoxShape3D.new()
box_shape.size = Vector3(100, 1, 100)
floor_collision.shape = box_shape
floor.add_child(floor_collision)
```

---

## Decision Tree: When to Go 3D

| Factor | Stay 2D | Go 3D |
|--------|---------|-------|
| **Gameplay** | Platformer, top-down, no depth needed | Exploration, first-person, 3D space combat |
| **Art budget** | Pixel art, limited resources | 3D models available or necessary |
| **Performance target** | Mobile, web, low-end | Desktop, console, high-end mobile |
| **Development time** | Limited | Have time for 3D learning curve |
| **Team skills** | 2D artists only | 3D artists or asset library |


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
