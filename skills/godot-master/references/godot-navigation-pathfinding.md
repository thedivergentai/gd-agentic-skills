> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Navigation & Pathfinding**. Accessed via Godot Master.

# Navigation & Pathfinding

Expert blueprint for AI pathfinding in 2D and 3D, utilizing `NavigationServer`, navigation agents, and avoidance system logic.

## Available Scripts

### [dynamic_nav_manager.gd](../scripts/godot-navigation-pathfinding_dynamic_nav_manager.gd)
Expert logic for managing navigation meshes at runtime. Supports Baking navigation polygons on the fly and updating paths for moving platforms or procedurally generated levels.


## NEVER Do

- **NEVER set `target_position` during `_ready()` without a deferment** — The `NavigationServer` is often not fully initialized when `_ready` is called. Use `call_deferred` to wait for the first physics frame before requesting a path.
- **NEVER use synchronous `bake_navigation_polygon()` at runtime** — Baking is a heavy operation. Doing it on the main thread will cause significant frame stutters. Use `NavigationServer2D` or background threading for dynamic updates.
- **NEVER forget to call `is_navigation_finished()`** — Continually requesting the `get_next_path_position()` after reaching a target will cause the AI to stutter or track back to old coordinates.
- **NEVER enable avoidance without a defined radius** — A `NavigationAgent` with a radius of 0 will not avoid other agents. Always match the agent's radius to its collision shape size.
- **NEVER recalculate paths 60 times a second** — Updating `target_position` in every `_process` call is expensive. Use a `Timer` to refresh paths at 0.1s or 0.2s intervals instead.
- **NEVER assume a path is always reachable** — If the destination is inside a wall or isolated, the agent may stand still or walk into a corner. Always validate with `is_target_reachable()`.

---

## 2D Navigation Setup
1. Use a `NavigationRegion2D` node.
2. Define a `NavigationPolygon` for the walkable floor area.
3. Attach a `NavigationAgent2D` to your `CharacterBody2D` enemy.

## 3D Navigation Setup
1. Use a `NavigationRegion3D` node.
2. Bake a `NavigationMesh` from the geometry of your level.
3. Attach a `NavigationAgent3D` to your `CharacterBody3D` units.

## Movement Logic Loop
In `_physics_process`:
1. Check if `is_navigation_finished()`.
2. Get `next_path_position()`.
3. Calculate direction: `(next_pos - global_position).normalized()`.
4. Apply velocity and `move_and_slide()`.

## Collaborative Avoidance
To prevent AI agents from overlapping:
- Enable `avoidance_enabled` on the agent.
- Connect to the `velocity_computed` signal.
- In `_physics_process`, call `set_velocity(safe_velocity)` instead of applying it directly.
- Apply the actual movement inside the `_on_velocity_computed` callback.

## Dynamic Obstacles
Add `NavigationObstacle2D/3D` nodes to moving objects like crates or elevators. The navigation system will automatically calculate paths around these obstacles in real-time.

## Reference
- [Godot Docs: Navigation Introduction](https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_2d.html)
- [Godot Docs: NavigationServer](https://docs.godotengine.org/en/stable/classes/class_navigationserver3d.html)
