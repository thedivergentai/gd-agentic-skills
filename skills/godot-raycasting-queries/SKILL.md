---
name: godot-raycasting-queries
description: "Expert blueprint for physics queries using RayCast, ShapeCast, and DirectSpaceState. Covers hit detection, volume overlap, mouse picking, and high-performance server-side intersection queries. Use when implementing projectiles, LOS, terrain grounding, or AI sensors. Keywords raycast, shapecast, direct_space_state, intersect_ray, intersect_shape, PhysicsRayQueryParameters, collision mask, mouse picking."
---

# Raycasting and Physics Queries

Physics queries allow for instantaneous detection of objects using lines (rays), volumes (shapes), or points.

## Available Scripts

### [direct_space_state_raycast.gd](scripts/direct_space_state_raycast.gd)
Expert usage of `PhysicsDirectSpaceState2D/3D` for bypassing node-based overhead in high-frequency queries.

### [shapecast_ground_detection.gd](scripts/shapecast_ground_detection.gd)
Reliable ground/footing detection using volume-based `ShapeCast` instead of thin rays.

### [multiple_hit_piercing_ray.gd](scripts/multiple_hit_piercing_ray.gd)
Implementing piercing projectiles that detect and return multiple hits in a single line.

### [field_of_view_scanner.gd](scripts/field_of_view_scanner.gd)
AI sensor logic using a fan of raycasts to detect targets within a FOV cone.

### [raycast_reflection_logic.gd](scripts/raycast_reflection_logic.gd)
Calculating bounces for lasers or bullets using collision normal reflection.

### [point_in_shape_query.gd](scripts/point_in_shape_query.gd)
Checking for overlapping physics bodies at a single point (Explosion epicenters).

### [rest_info_3d_stuck_fix.gd](scripts/rest_info_3d_stuck_fix.gd)
Using `get_rest_info` to detect stuck objects and resolve overlaps immediately.

### [mouse_pick_3d_query.gd](scripts/mouse_pick_3d_query.gd)
Converting 2D screen coordinates to 3D world rays for point-and-click interaction.

### [water_buoyancy_surface_calc.gd](scripts/water_buoyancy_surface_calc.gd)
Finding water surface height for buoyancy systems using high-to-low raycasting.

### [query_exclusion_optimization.gd](scripts/query_exclusion_optimization.gd)
Optimizing performance by excluding specific RIDs (Resource IDs) from intersection checks.

## NEVER Do in Physics Queries

- **NEVER access `direct_space_state` outside of `_physics_process()`** — The physics space can be locked or running on a separate thread; querying it in `_process()` is unsafe [1, 2].
- **NEVER use ShapeCast when a thin RayCast is sufficient** — Volume queries are significantly more expensive. Default to rays unless you need volumetric detection [3, 4].
- **NEVER assume results return `CollisionObject` nodes** — CSG shapes, `GridMap`, and `TileMapLayer` return themselves, not a generic physics body [5, 6].
- **NEVER assume `RayCast` nodes update instantly** — They update once per physics frame. If you move a node and query it immediately, you MUST call `force_raycast_update()` [3, 9].
- **NEVER use complex visual meshes for physics queries** — GPU-only data requires expensive thread locking to parse. Use simplified primitive collision shapes [10, 11].
- **NEVER iterate results to find the first valid hit** — Use `collision_mask` and `collision_layer` to filter queries at the server level for maximum performance.
- **NEVER forget to exclude the caster** — A ray starting from the center of a character will hit the character itself. Use `query.exclude = [self.get_rid()]` [20].
- **NEVER use rays for small, fast detection areas** — Rays can "tunnel" through thin walls if the frame rate drops. Use `cast_motion` or high-frequency stepping for bullets.
- **NEVER query 1000+ rays individually in GDScript** — Batch your queries or use the `PhysicsServer` directly in C++ if you reach extreme query counts.
- **NEVER ignore the `result.rid`** — RIDs are the fastest way to identify and exclude objects in subsequent queries, bypassing node-path lookups [20].

---

## 3D Mouse Picking Example

```gdscript
func screen_point_to_ray():
    var space_state = get_world_3d().direct_space_state
    var mouse_pos = get_viewport().get_mouse_position()
    
    var origin = project_ray_origin(mouse_pos)
    var end = origin + project_ray_normal(mouse_pos) * 2000
    
    var query = PhysicsRayQueryParameters3D.create(origin, end)
    var result = space_state.intersect_ray(query)
    
    if result:
        return result.collider
    return null
```

---

### Related
- `godot-2d-physics`, `godot-physics-3d`
- Master Skill: [godot-master](../godot-master/SKILL.md)
