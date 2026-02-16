> [!NOTE]
> **Resource Context**: This module provides expert patterns for **2D Physics**. Accessed via Godot Master.

# 2D Physics

Expert guidance for collision detection, triggers, and raycasting in Godot 2D.

## Available Scripts

### [collision_matrix.gd](../scripts/2d_physics_collision_matrix.gd)
Programmatic layer/mask management with named layer constants and debug visualization.

### [physics_query_cache.gd](../scripts/2d_physics_physics_query_cache.gd)
Frame-based caching for PhysicsDirectSpaceState2D queries - eliminates redundant expensive queries.

### [custom_physics.gd](../scripts/2d_physics_custom_physics.gd)
Custom physics integration patterns for CharacterBody2D. Covers non-standard gravity and forces.

### [physics_queries.gd](../scripts/2d_physics_physics_queries.gd)
PhysicsDirectSpaceState2D query patterns for raycasting, point queries, and shape queries.


## NEVER Do

- **NEVER scale CollisionShape2D nodes** — Use the shape handles in the editor, NOT the Node2D scale property.
- **NEVER confuse collision_layer with collision_mask** — Layer = "What AM I?", Mask = "What do I DETECT?".
- **NEVER multiply velocity by delta when using move_and_slide()** — move_and_slide() automatically includes timestep.
- **NEVER forget to call force_raycast_update() for manual raycasts** — Call this if you change target positions mid-frame.
- **NEVER use get_overlapping_bodies() every frame** — Use body_entered/body_exited signals instead.

---

## Collision Layers & Masks

### The Mental Model
- **collision_layer**: What broadcast channels am I transmitting on?
- **collision_mask**: What broadcast channels am I listening to?

### Best Practice Example
```gdscript
func setup_player_collision() -> void:
    set_collision_layer_value(1, true)   # Layer 1: Player
    set_collision_mask_value(2, true)    # Listen for Layer 2: Enemies
    set_collision_mask_value(3, true)    # Listen for Layer 3: World
```

## Area2D Expert Patterns

### unique_body_entered Detection
Avoid duplicate triggers when an Area2D has multiple collision shapes by using a Dictionary to track entered bodies.

### Damage-Over-Time
Implement DoT by tracking bodies in an Area2D and Applying damage via a timer or `_process` accumulator while they remain inside.

## Raycasting Patterns

### Manual Space Queries
Access `get_world_2d().direct_space_state` for one-shot ray, point, or shape queries that don't require permanent scene tree nodes.

```gdscript
func get_body_at_mouse() -> Node2D:
    var space := get_world_2d().direct_space_state
    var query := PhysicsPointQueryParameters2D.new()
    query.position = get_global_mouse_position()
    var results := space.intersect_point(query, 1)
    return results[0].collider if not results.is_empty() else null
```

## Reference
- [Godot Docs: 2D Physics](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html)
- [Godot Docs: Ray-casting](https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html)
