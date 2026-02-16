---
name: godot-2d-physics
description: "Expert patterns for Godot 2D physics including collision layers/masks, Area2D triggers, raycasting, and PhysicsDirectSpaceState2D queries. Use when implementing collision detection, trigger zones, line-of-sight systems, or manual physics queries. Trigger keywords: CollisionShape2D, CollisionPolygon2D, collision_layer, collision_mask, set_collision_layer_value, set_collision_mask_value, Area2D, body_entered, body_exited, RayCast2D, force_raycast_update, PhysicsPointQueryParameters2D, PhysicsShapeQueryParameters2D, direct_space_state, move_and_collide, move_and_slide."
---

# 2D Physics

Expert guidance for collision detection, triggers, and raycasting in Godot 2D.

## NEVER Do

- **NEVER scale CollisionShape2D nodes** — Use the shape handles in the editor, NOT the Node2D scale property. Scaling causes unpredictable physics behavior and incorrect collision normals.
- **NEVER confuse collision_layer with collision_mask** — Layer = "What AM I?", Mask = "What do I DETECT?". Setting both to the same value is almost always wrong.
- **NEVER multiply velocity by delta when using move_and_slide()** — move_and_slide() automatically includes timestep in calculations. Only multiply gravity (acceleration) by delta.
- **NEVER forget to call force_raycast_update() for manual raycasts** — Raycasts update once per physics frame. If you change target_position/rotation mid-frame, you MUST call force_raycast_update().
- **NEVER use get_overlapping_bodies() every frame** — Cache results with body_entered/body_exited signals instead. Continuous queries are expensive and unnecessary.

---

## Available Scripts

> **MANDATORY**: Read the script matching your use case before implementation.

### [collision_setup.gd](scripts/collision_setup.gd)
Programmatic layer/mask management with named layer constants and debug visualization.

### [physics_query_cache.gd](scripts/physics_query_cache.gd)
Frame-based caching for PhysicsDirectSpaceState2D queries - eliminates redundant expensive queries.

### [custom_physics.gd](scripts/custom_physics.gd)
Custom physics integration patterns for CharacterBody2D. Covers non-standard gravity, forces, and manual stepping. Use for non-standard physics behavior.

### [physics_queries.gd](scripts/physics_queries.gd)
PhysicsDirectSpaceState2D query patterns for raycasting, point queries, and shape queries. Use for line-of-sight, ground detection, or area scanning.

---

## Collision Layers & Masks (Bitmask Deep Dive)

### The Mental Model

```gdscript
# collision_layer (32 bits): What broadcast channels am I transmitting on?
# collision_mask (32 bits): What broadcast channels am I listening to?

# Example: Player vs Enemy
# Player:
#   layer = 0b0001 (Channel 1: "I am a player")
#   mask  = 0b0110 (Channels 2+3: "I listen for enemies and walls")
# Enemy:
#   layer = 0b0010 (Channel 2: "I am an enemy")
#   mask  = 0b0101 (Channels 1+3: "I listen for players and walls")
```

### Bitmask Helpers

```gdscript
# ✅ GOOD: Use helper functions for clarity
func setup_player_collision() -> void:
    # I am layer 1
    set_collision_layer_value(1, true)
    
    # I detect layers 2 (enemies) and 3 (world)
    set_collision_mask_value(2, true)
    set_collision_mask_value(3, true)

# ✅ GOOD: Bit shift for programmatic layer math
func enable_layers(base_layer: int, count: int) -> void:
    var mask := 0
    for i in range(count):
        mask |= (1 << (base_layer + i - 1))
    collision_mask = mask

# ❌ BAD: Hardcoded bitmasks without documentation
collision_mask = 0b110110  # What does this mean?!
```

### Common Patterns

```gdscript
# Pattern: Projectile that hits enemies but ignores other projectiles
# projectile.gd
extends Area2D

func _ready() -> void:
    set_collision_layer_value(4, true)   # Layer 4: "Projectiles"
    set_collision_mask_value(2, true)    # Mask Layer 2: "Enemies"
    # Result: Projectiles don't collide with each other

# Pattern: One-way platform (player can jump through from below)
# platform.gd
extends StaticBody2D

@export var one_way := true

func _ready() -> void:
    set_collision_layer_value(3, true)   # Layer 3: "World"
    if one_way:
        # Use Area2D + collision exemption instead
        # (Standard one-way platforms use different technique)
        pass
```

---

## Area2D Expert Patterns

### Problem: Duplicate Triggers on Multi-CollisionShape

```gdscript
# ❌ BAD: body_entered fires MULTIPLE times if Area2D has multiple shapes
extends Area2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    print("Entered!")  # Fires 3x if Area has 3 CollisionShapes!

# ✅ GOOD: Track unique bodies with Set
extends Area2D

var _active_bodies := {}  # Use dict as Set

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body not in _active_bodies:
        _active_bodies[body] = true
        print("First entrance!")  # Fires once

func _on_body_exited(body: Node2D) -> void:
    _active_bodies.erase(body)
```

### Damage-Over-Time with Immunity Frames

```gdscript
# lava_zone.gd
extends Area2D

@export var damage_per_tick := 5
@export var tick_rate := 0.5  # Damage every 0.5s

var _damage_timers := {}  # body -> time_until_next_tick

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("take_damage"):
        _damage_timers[body] = 0.0  # Immediate first tick

func _on_body_exited(body: Node2D) -> void:
    _damage_timers.erase(body)

func _process(delta: float) -> void:
    for body in _damage_timers.keys():
        _damage_timers[body] -= delta
        if _damage_timers[body] <= 0.0:
            body.take_damage(damage_per_tick)
            _damage_timers[body] = tick_rate
```

---

## RayCast2D Advanced Usage

### Dynamic Raycast Rotation

```gdscript
# enemy_vision.gd - Enemy looks toward player
extends CharacterBody2D

@onready var vision_ray: RayCast2D = $VisionRay

func can_see_target(target: Node2D) -> bool:
    var direction := global_position.direction_to(target.global_position)
    vision_ray.target_position = direction * 300  # 300px range
    vision_ray.force_raycast_update()  # CRITICAL: Update mid-frame
    
    if vision_ray.is_colliding():
        return vision_ray.get_collider() == target
    return false
```

### Multipa Raycasts for Ledge Detection

```gdscript
# platformer_controller.gd
extends CharacterBody2D

@onready var floor_front: RayCast2D = $FloorCheckFront
@onready var floor_back: RayCast2D = $FloorCheckBack

func at_ledge() -> bool:
    return floor_front.is_colliding() and not floor_back.is_colliding()

func _physics_process(delta: float) -> void:
    if at_ledge() and is_on_floor():
        # Enemy AI: Turn around at ledges
        velocity.x *= -1
```

### Raycast Exclusions

```gdscript
# Ignore specific bodies (e.g., self)
func _ready() -> void:
    $RayCast2D.add_exception(self)
    $RayCast2D.add_exception($Weapon)  # Ignore attached weapon collider

# Reset exclusions
$RayCast2D.clear_exceptions()
```

---

## PhysicsDirectSpaceState2D (Manual Queries)

### Point Query: Click Detection

```gdscript
# Check if mouse click hits any physics body
func get_body_at_mouse() -> Node2D:
    var mouse_pos := get_global_mouse_position()
    var space := get_world_2d().direct_space_state
    
    var query := PhysicsPointQueryParameters2D.new()
    query.position = mouse_pos
    query.collide_with_areas = false
    query.collision_mask = 0b11111111  # All layers
    
    var results := space.intersect_point(query, 1)  # Max 1 result
    if results.is_empty():
        return null
    return results[0].collider
```

### Shape Cast: AOE Attack

```gdscript
# AOE damage in circle around player
func damage_nearby_enemies(center: Vector2, radius: float, damage: int) -> void:
    var space := get_world_2d().direct_space_state
    var query := PhysicsShapeQueryParameters2D.new()
    
    var circle := CircleShape2D.new()
    circle.radius = radius
    query.shape = circle
    query.transform = Transform2D(0.0, center)
    query.collision_mask = 0b0010  # Layer 2: Enemies
    
    var hits := space.intersect_shape(query)
    for hit in hits:
        var enemy: Node2D = hit.collider
        if enemy.has_method("take_damage"):
            enemy.take_damage(damage)
```

### Ray Cast: Instant Hit Weapon

```gdscript
# Hitscan weapon (no projectile)
func fire_hitscan_weapon(from: Vector2, direction: Vector2, max_range: float) -> void:
    var space := get_world_2d().direct_space_state
    var query := PhysicsRayQueryParameters2D.create(from, from + direction * max_range)
    query.exclude = [self]
    query.collision_mask = 0b0010  # Enemies
    
    var result := space.intersect_ray(query)
    if result:
        var hit_enemy: Node2D = result.collider
        var hit_point: Vector2 = result.position
        
        spawn_hit_effect(hit_point)
        if hit_enemy.has_method("take_damage"):
            hit_enemy.take_damage(25)
```

---

## Decision Tree: Collision Detection Methods

| Use Case | Method | Why |
|----------|--------|-----|
| Continuous trigger zone | Area2D + signals | Memory of what's inside, signals are efficient |
| One-time pickup (coin) | Area2D + queue_free() on enter | Simple, automatic cleanup |
| Line-of-sight check | RayCast2D | Efficient, built-in |
| Click-to-select units | PhysicsPointQueryParameters2D | Single query, no permanent node |
| AOE spell | PhysicsShapeQueryParameters2D | One-shot query, flexible shape |
| Instant-hit weapon | PhysicsRayQueryParameters2D | Hitscan, no projectile physics |
| Platformer ground check | RayCast2D or raycast down | Precise ledge detection |

---

## Edge Cases

### Collision During _ready()

```gdscript
# ❌ BAD: Raycasts don't work in _ready() (physics not initialized)
func _ready() -> void:
    if $RayCast2D.is_colliding():  # Always false!
        print("Hit something")

# ✅ GOOD: Wait for physics frame
func _ready() -> void:
    await get_tree().physics_frame
    if $RayCast2D.is_colliding():
        print("Hit something")
```

### Area2D Not Detecting CharacterBody2D

```gdscript
# Problem: CharacterBody2D has collision_layer = 0 by default
# Solution: Explicitly set layer

# character.gd
func _ready() -> void:
    collision_layer = 0b0001  # Layer 1: Player
```

### Raycast Hitting Backfaces

```gdscript
# Raycasts hit both front and back of collision shapes
# To raycast one-way (front only), use Area2D monitoring
```

---

## Performance

```gdscript
# ✅ GOOD: Disable raycasts when not needed
func _ready() -> void:
    $OptionalRaycast.enabled = false

func check_vision() -> void:
    $OptionalRaycast.enabled = true
    $OptionalRaycast.force_raycast_update()
    var sees_player := $OptionalRaycast.is_colliding()
    $OptionalRaycast.enabled = false
    return sees_player

# ❌ BAD: Always-on raycasts for rarely-used checks
# Leave RayCast2D.enabled = true for vision checks once per second
```


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
