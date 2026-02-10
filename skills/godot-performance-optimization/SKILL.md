---
name: godot-performance-optimization
description: "Expert blueprint for performance profiling and optimization (frame drops, memory leaks, draw calls) using Godot Profiler, object pooling, visibility culling, and bottleneck identification. Use when diagnosing lag, optimizing for target FPS, or reducing memory usage. Keywords profiling, Godot Profiler, bottleneck, object pooling, VisibleOnScreenNotifier, draw calls, MultiMesh."
---

# Performance Optimization

Profiler-driven analysis, object pooling, and visibility culling define optimized game performance.

## Available Scripts

### [custom_performance_monitor.gd](scripts/custom_performance_monitor.gd)
Manager for adding and updating custom performance monitors in the Godot debugger.

### [multimesh_foliage_manager.gd](scripts/multimesh_foliage_manager.gd)
Expert MultiMesh pattern for rendering thousands of foliage instances efficiently.

## NEVER Do in Performance Optimization

- **NEVER optimize without profiling first** — "I think physics is slow" without data? Premature optimization. ALWAYS use Debug → Profiler (F3) to identify actual bottleneck.
- **NEVER use `print()` in release builds** — `print()` every frame = file I/O bottleneck + log spam. Use `@warning_ignore` or conditional `if OS.is_debug_build():`.
- **NEVER ignore `VisibleOnScreenNotifier2D` for  off-screen entities** — Enemies processing logic off-screen = wasted CPU. Disable `set_process(false)` when `screen_exited`.
- **NEVER instantiate nodes in hot loops** — `for i in 1000: var bullet = Bullet.new()` = 1000 allocations. Use object pools, reuse instances.
- **NEVER use `get_node()` in `_process()`** — Calling `get_node("Player")` 60x/sec = tree traversal spam. Cache in `@onready var player := $Player`.
- **NEVER forget to batch draw calls** — 1000 unique sprites = 1000 draw calls. Use TextureAtlas (sprite sheets) + MultiMesh for instanced rendering.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)
