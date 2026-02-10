---
name: godot-genre-platformer
description: "Expert blueprint for platformer games including precision movement (coyote time, jump buffering, variable jump height), game feel polish (squash/stretch, particle trails, camera shake), level design principles (difficulty curves, checkpoint placement), collectible systems (progression rewards), and accessibility options (assist mode, remappable controls). Based on Celeste/Hollow Knight design research. Trigger keywords: platformer, coyote_time, jump_buffer, game_feel, level_design, precision_movement."
---

# Genre: Platformer

Expert blueprint for platformers emphasizing movement feel, level design, and player satisfaction.

## NEVER Do

- **NEVER skip coyote time** — Without 6-frame grace period after leaving ledge, jumps feel unresponsive. Players blame themselves.
- **NEVER ignore jump buffering** — Pressing jump 6 frames before landing should queue jump. Missing this makes controls feel sluggish.
- **NEVER use fixed jump height** — Variable jump (hold longer = jump higher) gives players agency. Tap for short hop, hold for full jump.
- **NEVER forget camera smoothing** — Instant camera snapping causes motion sickness. Use position_smoothing or lerp for smooth follow.
- **NEVER skip squash/stretch on landing** — Landing without visual impact feels weightless. Add 0.1s squash on land for juice.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [advanced_platformer_controller.gd](scripts/advanced_platformer_controller.gd)
Complete platformer with coyote time, jump buffer, apex float, and variable gravity. Move_toward-based friction for polished game feel.

---

## Core Loop

`Jump → Navigate Obstacles → Reach Goal → Next Level`

## Skill Chain

`godot-project-foundations`, `godot-characterbody-2d`, `godot-input-handling`, `animation`, `sound-manager`, `tilemap-setup`, `camera-2d`

---

## Movement Feel ("Game Feel")

The most critical aspect of platformers. Players should feel **precise, responsive, and in control**.

### Input Responsiveness

```gdscript
# Instant direction changes - no acceleration on ground
func _physics_process(delta: float) -> void:
    var input_dir := Input.get_axis("move_left", "move_right")
    
    # Ground movement: instant response
    if is_on_floor():
        velocity.x = input_dir * MOVE_SPEED
    else:
        # Air movement: slightly reduced control
        velocity.x = move_toward(velocity.x, input_dir * MOVE_SPEED, AIR_ACCEL * delta)
```

### Coyote Time (Grace Period)

Allow jumping briefly after leaving a platform:

```gdscript
var coyote_timer: float = 0.0
const COYOTE_TIME := 0.1  # 100ms grace period

func _physics_process(delta: float) -> void:
    if is_on_floor():
        coyote_timer = COYOTE_TIME
    else:
        coyote_timer = max(0, coyote_timer - delta)
    
    # Can jump if on floor OR within coyote time
    if Input.is_action_just_pressed("jump") and coyote_timer > 0:
        velocity.y = JUMP_VELOCITY
        coyote_timer = 0
```

### Jump Buffering

Register jumps pressed slightly before landing:

```gdscript
var jump_buffer: float = 0.0
const JUMP_BUFFER_TIME := 0.15

func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("jump"):
        jump_buffer = JUMP_BUFFER_TIME
    else:
        jump_buffer = max(0, jump_buffer - delta)
    
    if is_on_floor() and jump_buffer > 0:
        velocity.y = JUMP_VELOCITY
        jump_buffer = 0
```

### Variable Jump Height

```gdscript
const JUMP_VELOCITY := -400.0
const JUMP_RELEASE_MULTIPLIER := 0.5

func _physics_process(delta: float) -> void:
    # Cut jump short when button released
    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= JUMP_RELEASE_MULTIPLIER
```

### Gravity Tuning

```gdscript
const GRAVITY := 980.0
const FALL_GRAVITY_MULTIPLIER := 1.5  # Faster falls feel better
const MAX_FALL_SPEED := 600.0

func apply_gravity(delta: float) -> void:
    var grav := GRAVITY
    if velocity.y > 0:  # Falling
        grav *= FALL_GRAVITY_MULTIPLIER
    velocity.y = min(velocity.y + grav * delta, MAX_FALL_SPEED)
```

---

## Level Design Principles

### The "Teaching Trilogy"

1. **Introduction**: Safe environment to learn mechanic
2. **Challenge**: Apply mechanic with moderate risk
3. **Twist**: Combine with other mechanics or time pressure

### Visual Language

- **Safe platforms**: Distinct color/texture
- **Hazards**: Red/orange tints, spikes, glow effects
- **Collectibles**: Bright, animated, particle effects
- **Secrets**: Subtle environmental hints

### Flow and Pacing

```
Easy → Easy → Medium → CHECKPOINT → Medium → Hard → CHECKPOINT → Boss
```

### Camera Design

```gdscript
# Look-ahead camera for platformers
extends Camera2D

@export var look_ahead_distance := 100.0
@export var look_ahead_speed := 3.0

var target_offset := Vector2.ZERO

func _process(delta: float) -> void:
    var player_velocity: Vector2 = target.velocity
    var desired_offset := player_velocity.normalized() * look_ahead_distance
    target_offset = target_offset.lerp(desired_offset, look_ahead_speed * delta)
    offset = target_offset
```

---

## Platformer Sub-Genres

### Precision Platformers (Celeste, Super Meat Boy)

- Instant respawn on death
- Very tight controls (no acceleration)
- Checkpoints every few seconds of gameplay
- Death is learning, not punishment

### Collectathon (Mario 64, Banjo-Kazooie)

- Large hub worlds with objectives
- Multiple abilities unlocked over time
- Backtracking encouraged
- Stars/collectibles as progression gates

### Puzzle Platformers (Limbo, Inside)

- Slow, deliberate pacing
- Environmental puzzles
- Physics-based mechanics
- Atmospheric storytelling

### Metroidvania (Hollow Knight)

- See `godot-genre-metroidvania` skill
- Ability-gated exploration
- Interconnected world map

---

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Floaty jumps | Increase gravity, especially on descent |
| Imprecise landings | Add coyote time and visual landing feedback |
| Unfair deaths | Ensure hazards are clearly visible before encountered |
| Blind jumps | Camera look-ahead or zoom out during falls |
| Boring mid-game | Introduce new mechanics every 2-3 levels |

---

## Polish Checklist

- [ ] Dust godot-particles on land/run
- [ ] Screen shake on heavy landings
- [ ] Squash/stretch animations
- [ ] Sound effects for every action (jump, land, wall-slide)
- [ ] Death and respawn animations
- [ ] Checkpoint visual/audio feedback
- [ ] Accessible difficulty options (assist mode)

---

## Godot-Specific Tips

1. **CharacterBody2D vs RigidBody2D**: Always use `CharacterBody2D` for platformer characters - precise control is essential
2. **Physics tick rate**: Consider 120Hz physics for smoother movement
3. **One-way platforms**: Use `set_collision_mask_value()` or dedicated collision layers
4. **Wall detection**: Use `is_on_wall()` and `get_wall_normal()` for wall jumps

---

## Example Games for Reference

- **Celeste** - Perfect game feel, assist mode accessibility
- **Hollow Knight** - Combat + platforming integration
- **Super Mario Bros. Wonder** - Visual polish and surprises
- **Shovel Knight** - Retro mechanics with modern feel


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
