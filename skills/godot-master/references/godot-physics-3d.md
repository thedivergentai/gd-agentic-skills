> [!NOTE]
> **Resource Context**: This module provides expert patterns for **3D Physics**. Accessed via Godot Master.

# 3D Physics (Jolt/Native)

Expert guidance for high-performance 3D physics, including ragdolls, physical bones, and advanced constraints.

## Available Scripts

### [ragdoll_manager.gd](../scripts/godot-physics-3d_ragdoll_manager.gd)
Expert manager for transitioning `Skeleton3D` from animation to physical simulation (death effect). Handles impulse application and bone cleanup.

### [raycast_visualizer.gd](../scripts/godot-physics-3d_raycast_visualizer.gd)
Debug tool to visualize hit points and normals of `RayCast3D` in-game for easier debugging of spatial logic.


## NEVER Do

- **NEVER scale RigidBody3D nodes** — Scaling the body breaks physics calculations. Always scale the individual `CollisionShape3D` nodes instead.
- **NEVER use `move_and_slide` inside `_process`** — Physics logic must stay in `_physics_process` to ensure stability and framerate independence.
- **NEVER simulate ragdolls continuously** — Ragdolls are CPU-intensive. Enable physical bones only when needed (e.g., on death) and disable them once the body comes to a rest.
- **NEVER use `ConcaveCollisionShape3D` for dynamic bodies** — Trimesh shapes are for static environment geometry only. Use Convex or Primitive shapes for anything that moves.
- **NEVER ignore the Godot Jolt plugin** — For Godot 4.x, Jolt is significantly more stable and performant than the default physics engine.

---

## Ragdoll Implementation
Godot uses `PhysicalBone3D` nodes attached to a `Skeleton3D`. 
1. Select your `Skeleton3D`.
2. Click "Create Physical Skeleton" to auto-generate the bone structure.
3. Use `physical_bones_start_simulation()` at runtime to trigger the effect.

## Joints & Constraints
The `Generic6DOFJoint3D` is the most flexible joint type, capable of simulating hinges, sliders, and ball-and-socket joints through unified configuration.

## Raycasting in 3D
Use `PhysicsDirectSpaceState3D` for programmatic raycasts or the `RayCast3D` node for editor-based setup. Always ensure your raycast mask matches the intended target layer.

## Reference
- [Godot Docs: 3D Physics](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html)
- [Godot Jolt GitHub](https://github.com/godot-jolt/godot-jolt)
