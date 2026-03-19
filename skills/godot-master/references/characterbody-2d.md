---
name: godot-characterbody-2d
description: "Expert patterns for CharacterBody2D including platformer movement (coyote time, jump buffering, variable jump height), top-down movement (8-way, tank controls), collision handling, one-way platforms, and state machines. Use for player characters, NPCs, or enemies. Trigger keywords: CharacterBody2D, move_and_slide, is_on_floor, coyote_time, jump_buffer, velocity, get_slide_collision, one_way_platforms, state_machine."
---

# CharacterBody2D Implementation

Expert guidance for player-controlled 2D movement using Godot's physics system.

## NEVER Do

- **NEVER use `RigidBody2D` for standard player controllers** — RigidBody is for physics-simulated objects. For responsive, feel-driven player movement, always use `CharacterBody2D`.
- **NEVER multiply `velocity` by `delta` before `move_and_slide()`** — `move_and_slide()` handles delta internally. Manual multiplication makes movement framerate-dependent [12].
- **NEVER use `global_position` updates for movement** — Use `velocity` and `move_and_slide()`. Direct position updates bypass collision detection and floor snapping.
- **NEVER ignore the return value of `move_and_slide()`** — While optional, checking `is_on_floor()` or `get_last_motion()` immediately after is critical for state logic.
- **NEVER rely on default `floor_snap_length` for fast stair-climbing** — Default snapping is too small for high-velocity characters. Use custom raycast-based stair logic for smooth transitions.
- **NEVER apply gravity while `is_on_floor()` is true** — Constant downward force on the floor can cause "micro-jitter" or prevent floor-snap from working correctly. Reset `velocity.y` to 0 or a small constant.
- **NEVER use `Area2D` for ground detection** — Real collisions (rays/shapecasts) are more precise. `is_on_floor()` is highly optimized; only augment it if necessary.
- **NEVER forget Ceiling Bonk detection** — If you don't reset `velocity.y` to 0 when `is_on_ceiling()`, the player will "float" against the ceiling until gravity pulls them down.
- **NEVER use high-precision physics for pixel art visuals** — Keep physics math high-precision, but round your Sprite nodal positions in `_process` to avoid visual sub-pixel jitter.
- **NEVER use `queue_free()` on characters every frame** — Use object pooling for bullets or enemies to avoid SceneTree performance spikes.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [frame_perfect_coyote_time.gd](../scripts/characterbody_2d_frame_perfect_coyote_time.gd)
Professional platformer mechanics: Coyote Time (jump after fall) and Input Buffering.

### [slope_stair_snapping.gd](../scripts/characterbody_2d_slope_stair_snapping.gd)
Advanced procedural stair-climbing and smooth slope snapping logic.

### [variable_jump_height.gd](../scripts/characterbody_2d_variable_jump_height.gd)
Customizable 'Short Hop' vs 'Full Jump' implementation based on input duration.

### [wall_slide_jump_refined.gd](../scripts/characterbody_2d_wall_slide_jump_refined.gd)
Responsive Wall Slide and Wall Jump mechanics with proper push-back forces.

### [dash_state_controller.gd](../scripts/characterbody_2d_dash_state_controller.gd)
State-based dash logic with invincibility frames and customizable cooldowns.

### [subpixel_movement_rounding.gd](../scripts/characterbody_2d_subpixel_movement_rounding.gd)
Expert pattern for maintaining pixel-perfect visuals in low-res games while keeping smooth physics.

### [performance_character_pooling.gd](../scripts/characterbody_2d_performance_character_pooling.gd)
Logic for optimizing 100+ active characters using visibility-based physics toggling.

### [impulse_response_handler.gd](../scripts/characterbody_2d_impulse_response_handler.gd)
Expert handling of external forces (Knockback, Blow-back, Wind) integrated with `move_and_slide`.

### [aerial_drift_acceleration.gd](../scripts/characterbody_2d_aerial_drift_acceleration.gd)
Precise air control and acceleration logic for professional platformer feel.

### [ceiling_bonk_detection.gd](../scripts/characterbody_2d_ceiling_bonk_detection.gd)
Fixing 'sticky head' syndrome by correctly handling vertical momentum on ceiling hits.

### [expert_physics_2d.gd](../scripts/characterbody_2d_expert_physics_2d.gd)
Complete platformer movement with coyote time, jump buffering, smooth acceleration/friction, and sub-pixel stabilization. Uses move_toward for precise control.

### [dash_controller.gd](../scripts/characterbody_2d_dash_controller.gd)
Frame-perfect dash with I-frames, cooldown, and momentum preservation.

### [wall_jump_controller.gd](../scripts/characterbody_2d_wall_jump_controller.gd)
Wall slide, cling, and directional wall jump with auto-correction.

> **Do First**: Read expert_physics_2d.gd for platformer foundation before adding dash/wall-jump.

---

## When to Use CharacterBody2D

**Use CharacterBody2D For:**
- Player characters (platformer, top-down, side-scroller)
- NPCs with custom movement logic
- Enemies with non-physics-based movement

**Use RigidBody2D For:**
- Physics-driven objects (rolling boulders, vehicles)
- Objects affected by forces and impulses

## Platformer Movement Pattern

### Basic Platformer Controller

```gdscript
extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

# Get the gravity from the project settings
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
    # Apply gravity
    if not is_on_floor():
        velocity.y += gravity * delta
    
    # Handle jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
    
    # Get input direction
    var direction := Input.get_axis("move_left", "move_right")
    
    # Apply movement
    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
    
    move_and_slide()
```

### Advanced Platformer with Coyote Time & Jump Buffer

```gdscript
extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const ACCELERATION := 1500.0
const FRICTION := 1200.0
const AIR_RESISTANCE := 200.0

# Coyote time: grace period after leaving platform
const COYOTE_TIME := 0.1
var coyote_timer := 0.0

# Jump buffering: remember jump input slightly before landing
const JUMP_BUFFER_TIME := 0.1
var jump_buffer_timer := 0.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
    # Gravity
    if not is_on_floor():
        velocity.y += gravity * delta
        coyote_timer -= delta
    else:
        coyote_timer = COYOTE_TIME
    
    # Jump buffering
    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = JUMP_BUFFER_TIME
    else:
        jump_buffer_timer -= delta
    
    # Jump (with coyote time and buffer)
    if jump_buffer_timer > 0 and coyote_timer > 0:
        velocity.y = JUMP_VELOCITY
        jump_buffer_timer = 0
        coyote_timer = 0
    
    # Variable jump height
    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= 0.5
    
    # Movement with acceleration/friction
    var direction := Input.get_axis("move_left", "move_right")
    
    if direction:
        velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
    else:
        var friction_value := FRICTION if is_on_floor() else AIR_RESISTANCE
        velocity.x = move_toward(velocity.x, 0, friction_value * delta)
    
    move_and_slide()
```

## Top-Down Movement Pattern

### 8-Directional Top-Down

```gdscript
extends CharacterBody2D

const SPEED := 200.0
const ACCELERATION := 1500.0
const FRICTION := 1000.0

func _physics_process(delta: float) -> void:
    # Get input direction (normalized for diagonal movement)
    var input_vector := Input.get_vector(
        "move_left", "move_right",
        "move_up", "move_down"
    )
    
    if input_vector != Vector2.ZERO:
        # Accelerate toward target velocity
        velocity = velocity.move_toward(
            input_vector * SPEED,
            ACCELERATION * delta
        )
    else:
        # Apply friction
        velocity = velocity.move_toward(
            Vector2.ZERO,
            FRICTION * delta
        )
    
    move_and_slide()
```

### Top-Down with Rotation (Tank Controls)

```gdscript
extends CharacterBody2D

const SPEED := 200.0
const ROTATION_SPEED := 3.0

func _physics_process(delta: float) -> void:
    # Rotation
    var rotate_direction := Input.get_axis("rotate_left", "rotate_right")
    rotation += rotate_direction * ROTATION_SPEED * delta
    
    # Forward/backward movement
    var move_direction := Input.get_axis("move_backward", "move_forward")
    velocity = transform.x * move_direction * SPEED
    
    move_and_slide()
```

## Collision Handling

### Detecting Floor/Walls/Ceiling

```gdscript
func _physics_process(delta: float) -> void:
    move_and_slide()
    
    if is_on_floor():
        print("Standing on ground")
    
    if is_on_wall():
        print("Touching wall")
    
    if is_on_ceiling():
        print("Hitting ceiling")
```

### Get Collision Information

```gdscript
func _physics_process(delta: float) -> void:
    move_and_slide()
    
    # Process each collision
    for i in get_slide_collision_count():
        var collision := get_slide_collision(i)
        print("Collided with: ", collision.get_collider().name)
        print("Collision normal: ", collision.get_normal())
        
        # Example: bounce off walls
        if collision.get_collider().is_in_group("bouncy"):
            velocity = velocity.bounce(collision.get_normal())
```

### One-Way Platforms

```gdscript
extends CharacterBody2D

func _physics_process(delta: float) -> void:
    # Allow falling through platforms by pressing down
    if Input.is_action_pressed("move_down") and is_on_floor():
        position.y += 1  # Move slightly down to pass through
    
    velocity.y += gravity * delta
    move_and_slide()
```

## Movement States with State Machine

```gdscript
extends CharacterBody2D

enum State { IDLE, RUNNING, JUMPING, FALLING, DASHING }

var current_state := State.IDLE
var dash_velocity := Vector2.ZERO
const DASH_SPEED := 600.0
const DASH_DURATION := 0.2
var dash_timer := 0.0

func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            _state_idle(delta)
        State.RUNNING:
            _state_running(delta)
        State.JUMPING:
            _state_jumping(delta)
        State.FALLING:
            _state_falling(delta)
        State.DASHING:
            _state_dashing(delta)

func _state_idle(delta: float) -> void:
    velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
    
    if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
        current_state = State.RUNNING
    elif Input.is_action_just_pressed("jump"):
        current_state = State.JUMPING
    
    move_and_slide()

func _state_dashing(delta: float) -> void:
    dash_timer -= delta
    velocity = dash_velocity
    
    if dash_timer <= 0:
        current_state = State.IDLE
    
    move_and_slide()
```

## Best Practices

### 1. Use Constants for Tuning

```gdscript
# ✅ Good - easy to tweak
const SPEED := 300.0
const JUMP_VELOCITY := -400.0

# ❌ Bad - magic numbers
velocity.x = 300
velocity.y = -400
```

### 2. Use `@export` for Designer Control

```gdscript
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export_range(0, 2000) var acceleration: float = 1500.0
```

### 3. Separate Movement from Animation

```gdscript
func _physics_process(delta: float) -> void:
    _handle_movement(delta)
    _handle_animation()
    move_and_slide()

func _handle_movement(delta: float) -> void:
    # Movement logic only
    pass

func _handle_animation() -> void:
    # Animation state changes only
    if velocity.x > 0:
        $AnimatedSprite2D.flip_h = false
    elif velocity.x < 0:
        $AnimatedSprite2D.flip_h = true
```

### 4. Use Floor Detection Parameters

```gdscript
func _ready() -> void:
    # Set floor parameters
    floor_max_angle = deg_to_rad(45)  # Max slope angle
    floor_snap_length = 8.0  # Distance to snap to floor
    motion_mode = MOTION_MODE_GROUNDED  # Vs MOTION_MODE_FLOATING
```

## Common Gotchas

**Issue**: Character slides on slopes
```gdscript
# Solution: Increase friction
const FRICTION := 1200.0
```

**Issue**: Character stutters on moving platforms
```gdscript
# Solution: Enable platform snap
func _physics_process(delta: float) -> void:
    move_and_slide()
    
    # Snap to platform velocity
    if is_on_floor():
        var floor_velocity := get_platform_velocity()
        velocity += floor_velocity
```

**Issue**: Double jump exploit
```gdscript
# Solution: Track if jump was used
var can_jump := true

func _physics_process(delta: float) -> void:
    if is_on_floor():
        can_jump = true
    
    if Input.is_action_just_pressed("jump") and can_jump:
        velocity.y = JUMP_VELOCITY
        can_jump = false
```

## Reference
- [Godot Docs: CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
- [Godot Docs: Using CharacterBody2D](https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html)


### Related
- Master Skill: [godot-master](../SKILL.md)
