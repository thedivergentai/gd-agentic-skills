---
name: godot-physics-3d
description: "Expert patterns for Godot 3D physics (Jolt/PhysX), including Ragdolls, PhysicalBones, Joint3D constraints, RayCasting optimizations, and collision layers. Use for rigid body simulations, character physics, or complex interactions. Trigger keywords: RigidBody3D, PhysicalBone3D, Jolt, Ragdoll, Skeleton3D, Joint3D, PinJoint3D, HingeJoint3D, Generic6DOFJoint3D, RayCast3D, PhysicsDirectSpaceState3D."
---

# 3D Physics (Jolt/Native)

Expert guidance for high-performance 3D physics and ragdolls.

## NEVER Do

- **NEVER move `PhysicsBody3D` nodes in `_process()`** — Use `_physics_process()`. Moving bodies outside the physics step causes visual jitter and unreliable collision detection [12, 13].
- **NEVER scale collision shapes directly** — Scaling physics shapes causes instability, inaccurate normals, and jitter. Use the `shape` properties (height, radius, size) instead.
- **NEVER modify `RigidBody3D` transforms directly** — This ignores the physics solver. Use `apply_impulse()`, `apply_torque()`, or the `_integrate_forces()` callback for safe manipulation [17].
- **NEVER use `RigidBody3D` for platformer player controllers** — RigidBody is for objects driven by physics. For refined movement, use `CharacterBody3D` with `move_and_slide()` [move_and_slide].
- **NEVER leave Continuous CD (CCD) enabled for static meshes** — It adds heavy CPU cost. Reserve it for high-speed small objects (bullets) to prevent them from passing through walls.
- **NEVER use `PhysicsServer3D` RIDs without manual cleanup** — RIDs are not garbage collected. If you create bodies via the server, you MUST call `free_rid()` when done to avoid memory leaks.
- **NEVER use `RayCast3D` for precise ground detection on stairs** — A single ray is too thin. Use `ShapeCast3D` with a cylinder or sphere shape to detect walkable steps reliably [Stair Logic].
- **NEVER rely on `VehicleBody3D` for non-racing arcade vehicles** — It's a complex sim. For arcade hovercraft or simple cars, a custom `CharacterBody3D` with Raycasts is often easier to tune.
- **NEVER forget to set `collision_layer` and `collision_mask` properly** — If everything is on layer 1, performance will tank from redundant checks. Categorize your world.
- **NEVER use `Area3D` for high-frequency blocking** — Areas are for detection. For walls/barriers, use `StaticBody3D` to ensure immediate, robust containment.

---

## Available Scripts

### [physics_server_3d_bullets.gd](../scripts/physics_3d_physics_server_3d_bullets.gd)
Direct `PhysicsServer3D` RID management for thousands of high-speed 3D projectiles.

### [ray_query_3d_vision.gd](../scripts/physics_3d_ray_query_3d_vision.gd)
Expert line-of-sight and AI vision logic using low-level space state interrupts.

### [shapecast_3d_ground_check.gd](../scripts/physics_3d_shapecast_3d_ground_check.gd)
Robust stair and ledge detection using `ShapeCast3D` for 3D CharacterBody stability.

### [physics_ccd_3d_projectile.gd](../scripts/physics_3d_physics_ccd_3d_projectile.gd)
Continuous Collision Detection configuration and sub-stepping logic for anti-tunneling.

### [physics_layers_3d_config.gd](../scripts/physics_3d_physics_layers_3d_config.gd)
Clean collision matrix architecture for 3D using named bitmask layers and masks.

### [custom_gravity_well_3d.gd](../scripts/physics_3d_custom_gravity_well_3d.gd)
Planet-style gravity wells and zero-G zones implemented via priority Area3D nodes.

### [soft_body_3d_interaction.gd](../scripts/physics_3d_soft_body_3d_interaction.gd)
Managing high-performance SoftBody3D flags, cloaks, and foliage attachments.

### [joint_3d_breakage_logic.gd](../scripts/physics_3d_joint_3d_breakage_logic.gd)
Dynamic joint stress monitoring and procedural snaps for destructible 3D objects.

### [kinematic_3d_stairs_logic.gd](../scripts/physics_3d_kinematic_3d_stairs_logic.gd)
Advanced procedural stair-stepping and snapping for professional 3D character controllers.

### [vehicle_simulation_tuning.gd](../scripts/physics_3d_vehicle_simulation_tuning.gd)
Tuning `VehicleBody3D` and `VehicleWheel3D` for high-speed drifting and arcade feel.

### [ragdoll_manager.gd](../scripts/physics_3d_ragdoll_manager.gd)
Expert manager for transitioning Skeleton3D from animation to physical simulation (death effect). Handles impulse application and cleanup.

### [raycast_visualizer.gd](../scripts/physics_3d_raycast_visualizer.gd)
Debug tool to visualize hit points and normals of RayCast3D in game.

## Core Architecture

### 1. Layers & Masks (3D)
Same as 2D:
- **Layer**: What object IS.
- **Mask**: What object HITS.

### 2. Physical Bones (Ragdolls)
Godot uses `PhysicalBone3D` nodes attached to `Skeleton3D` bones.
To setup:
1. Select Skeleton3D.
2. Click "Create Physical Skeleton" in top menu.
3. This generates `PhysicalBone3D` nodes.

### 3. Jolt Joints
Use `Generic6DOFJoint3D` for almost everything. It covers hinge, slider, and ball-socket needs with simpler configuration than specific nodes.

---

## Ragdoll Implementation

```gdscript
# simple_ragdoll.gd
extends Skeleton3D

func start_ragdoll() -> void:
    physical_bones_start_simulation()
    
func stop_ragdoll() -> void:
    physical_bones_stop_simulation()
```


## Reference
- Master Skill: [godot-master](../SKILL.md)
