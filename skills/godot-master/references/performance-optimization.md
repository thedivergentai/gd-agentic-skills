---
name: godot-performance-optimization
description: "Expert blueprint for performance profiling and optimization (frame drops, memory leaks, draw calls) using Godot Profiler, object pooling, visibility culling, and bottleneck identification. Use when diagnosing lag, optimizing for target FPS, or reducing memory usage. Keywords profiling, Godot Profiler, bottleneck, object pooling, VisibleOnScreenNotifier, draw calls, MultiMesh."
---

# Performance Optimization

Profiler-driven analysis, object pooling, and visibility culling define optimized game performance.

## Available Scripts

### [worker_thread_pool_manager.gd](../scripts/performance_optimization_worker_thread_pool_manager.gd)
Expert logic for offloading heavy computation to Godot 4's WorkerThreadPool for multi-threaded processing.

### [object_pool_system.gd](../scripts/performance_optimization_object_pool_system.gd)
Minimal allocation strategy using node visibility and process toggling instead of constant instantiation.

### [rendering_server_direct.gd](../scripts/performance_optimization_rendering_server_direct.gd)
Bypassing the SceneTree logic for massive canvas item rendering directly via the RenderingServer.

### [low_level_physics_query.gd](../scripts/performance_optimization_low_level_physics_query.gd)
High-performance direct physics space state queries, faster than using RayCast nodes for hundreds of checks.

### [custom_monitor_profiler.gd](../scripts/performance_optimization_custom_monitor_profiler.gd)
Implementation of real-time performance monitoring using Performance.get_monitor() for bottleneck detection.

### [manual_culling_logic.gd](../scripts/performance_optimization_manual_culling_logic.gd)
Disabling off-screen logic manually using VisibilityNotifiers to cull CPU-heavy processing.

### [shared_resource_strategy.gd](../scripts/performance_optimization_shared_resource_strategy.gd)
Expert management of Local-to-Scene vs Shared resources to balance memory usage and unique instance states.

### [texture_array_batching.gd](../scripts/performance_optimization_texture_array_batching.gd)
Reducing draw calls and state changes by utilizing TextureArrays for multi-item shader-based batching.

### [multimesh_optimizer.gd](../scripts/performance_optimization_multimesh_optimizer.gd)
Rendering thousands of animated mesh instances via hardware instancing (MultiMeshInstance3D).

### [navigation_agent_optimization.gd](../scripts/performance_optimization_navigation_agent_optimization.gd)
Staggered path update strategy for massive AI crowds to prevent pathfinding bottlenecks in a single frame.

## NEVER Do in Performance Optimization

- **NEVER optimize without profiling first** — "I think physics is slow" without data? Premature optimization. ALWAYS use Debug → Profiler (F3) to identify actual bottleneck [20].
- **NEVER use `print()` in release builds** — `print()` every frame = file I/O bottleneck + log spam. Use `@warning_ignore` or conditional `if OS.is_debug_build():` [21].
- **NEVER ignore `VisibleOnScreenNotifier2D` for off-screen entities** — Enemies processing logic off-screen = wasted CPU. Disable `set_process(false)` when `screen_exited` [22].
- **NEVER instantiate nodes in hot loops** — `for i in 1000: var bullet = Bullet.new()` = 1000 allocations. Use object pools, reuse instances [23].
- **NEVER use `get_node()` in `_process()`** — Calling `get_node("Player")` 60x/sec = tree traversal spam. Cache in `@onready var player := $Player` [24].
- **NEVER forget to batch draw calls** — 1000 unique sprites = 1000 draw calls. Use TextureAtlas (sprite sheets) + MultiMesh for instanced rendering [25].
- **NEVER block the main thread for heavy operations** — Avoid `OS.delay_msec()` or long synchronous data processing. Use `WorkerThreadPool` to keep framerates steady.
- **NEVER use complex collision shapes for physics queries** — High-poly convex shapes are expensive to resolve. Prefer simplified primitives (Circle, Rectangle, Box).
- **NEVER forget to disconnect local lambda signals** — Anonymous lambdas connected to global signals can cause memory leaks if the capturing object is freed.
- **NEVER use large textures without compression** — VRAM is limited. Use VRAM Compressed (S3TC/BPTC) for fast lookup and reduced memory footprint.
- **NEVER perform tree modifications during physics steps** — Adding/removing nodes during `_inter_ray` or `_physics_process` can lock the physics server. Use `call_deferred`.

---

**Debug → Profiler** (F3)

Tabs:
- **Time**: Function call times
- **Memory**: RAM usage
- **Network**: RPCs, bandwidth
- **Physics**: Collision checks

## Common Optimizations

### Object Pooling

```gdscript
var bullet_pool: Array[Node] = []

func get_bullet() -> Node:
    if bullet_pool.is_empty():
        return Bullet.new()
    return bullet_pool.pop_back()

func return_bullet(bullet: Node) -> void:
    bullet.hide()
    bullet_pool.append(bullet)
```

### Visibility Notifier

```gdscript
# Add VisibleOnScreenNotifier2D
# Disable processing when off-screen
func _on_screen_exited() -> void:
    set_process(false)

func _on_screen_entered() -> void:
    set_process(true)
```

### Reduce Draw Calls

```
# Use TextureAtlas (sprite sheets)
# Batch similar materials
# Fewer unique textures
```

## Reference
- [Godot Docs: Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html)


### Related
- Master Skill: [godot-master](../SKILL.md)
