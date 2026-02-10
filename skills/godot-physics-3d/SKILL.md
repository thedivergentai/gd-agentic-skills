---
name: godot-physics-3d
description: "Expert patterns for Godot 3D physics (Jolt/PhysX), including Ragdolls, PhysicalBones, Joint3D constraints, RayCasting optimizations, and collision layers. Use for rigid body simulations, character physics, or complex interactions. Trigger keywords: RigidBody3D, PhysicalBone3D, Jolt, Ragdoll, Skeleton3D, Joint3D, PinJoint3D, HingeJoint3D, Generic6DOFJoint3D, RayCast3D, PhysicsDirectSpaceState3D."
---

# 3D Physics (Jolt/Native)

Expert guidance for high-performance 3D physics and ragdolls.

## NEVER Do

- **NEVER scale RigidBody3D** — Scale collision shapes, NEVER the body itself. Non-uniform scaling breaks physics engines logic.
- **NEVER use `move_and_slide` inside `_process`** — Always use `_physics_process`. Frame-rate dependency kills simulation stability.
- **NEVER simulate ragdolls 24/7** — Only enable physical bones on death or impact. Animate static meshes otherwise to save CPU.
- **NEVER ignore Jolt** — Godot Jolt plugin is strictly superior to default Godot Physics in 4.x for stability and performance. Use it if possible.
- **NEVER use ConcaveCollisionShape3D for dynamic bodies** — Concave shapes (Trimesh) are for static ground only. Moving bodies MUST be Convex or Primitive (Box/Capsule).

---

## Available Scripts

### [ragdoll_manager.gd](scripts/ragdoll_manager.gd)
Expert manager for transitioning Skeleton3D from animation to physical simulation (death effect). Handles impulse application and cleanup.

### [raycast_visualizer.gd](scripts/raycast_visualizer.gd)
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
- Master Skill: [godot-master](../godot-master/SKILL.md)
