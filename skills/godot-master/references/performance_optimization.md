> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Performance Optimization**. Accessed via Godot Master.

# Performance Optimization

Expert guidance for identifying bottlenecks, reducing draw calls, and optimizing CPU/GPU usage in Godot.

## Available Scripts

### [custom_performance_monitor.gd](../scripts/performance_optimization_custom_performance_monitor.gd)
Utility for registering custom metrics (e.g., "Active Projectiles", "Pathfinding Requests") to Godot's built-in Profiler for real-time analysis.

### [multimesh_foliage_manager.gd](../scripts/performance_optimization_multimesh_foliage_manager.gd)
Demonstrates the `MultiMeshInstance` pattern. Efficiently renders thousands of identical meshes (like grass or trees) in a single draw call.


## NEVER Do

- **NEVER optimize blindly without data** — Premature optimization is the root of all evil. Always identify your specific bottleneck (Script, Physics, Render) using the **Profiler (F3)** before changing code.
- **NEVER use `print()` in hot loops or release builds** — Console output is slow I/O. Frequent prints can single-handedly drop your FPS. Use labels in a debug UI instead.
- **NEVER process entities that are far off-screen** — Use `VisibleOnScreenNotifier2D/3D` to disable `_process`, `_physics_process`, and animations when an object is not visible to the player.
- **NEVER instantiate/free nodes repeatedly** — `instantiate()` is a heavy allocation. Use **Object Pooling** to reuse bullets, effects, and enemies.
- **NEVER use `get_node()` or `$` inside `_process()`** — Caching references in `@onready` variables is mandatory. Don't waste CPU cycles traversing the scene tree every frame.
- **NEVER ignore Draw Call counts** — 1000 unique sprites result in 1000 draw calls. Use **Texture Atlases** and `MultiMesh` to batch similar objects into a single call.

---

## Profiling Strategy
1. **Frame Time**: Target < 16.6ms for 60 FPS.
2. **CPU Bottleneck**: Usually caused by script logic (big loops), complex physics, or excessive signal traffic.
3. **GPU Bottleneck**: Usually caused by high fragment shader complexity (overdraw), expensive lighting, or too many draw calls.

## Optimization Patterns

### Object Pooling
Maintain a `pool` array. When a new object is needed, pop it from the pool. When finished, disable/hide it and push it back to the pool rather than calling `queue_free()`.

### MultiMeshInstance
For rendering large amounts of identical geometry (foliage, debris):
- Use `MultiMesh`.
- Set the `buffer` of instance transforms once (or sparsely).
- Result: 1 draw call instead of thousands.

### Physics Optimization
- Use the **Jolt Physics** plugin for Godot 4.x.
- Simplify collision shapes: prefer primitive boxes/cylinders over concave trimesh shapes.
- Reduce physics ticks per second in Project Settings if precision isn't critical.

## Threading
Move long-running data calculations (e.g., procedural world gen, large file IO) to a background thread using `WorkerThreadPool` to prevent frame stutters.

## Reference
- [Godot Docs: General Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html)
- [Godot Docs: Using MultiMeshInstance](https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh_instance.html)
