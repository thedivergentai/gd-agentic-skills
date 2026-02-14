> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Debugging & Profiling**. Accessed via Godot Master.

# Debugging & Profiling

Expert guidance for efficiently finding bugs and profiling performance using Godot's built-in tools and custom debug overlays.

## Available Scripts

### [performance_plotter.gd](../scripts/godot-debugging-profiling_performance_plotter.gd)
Custom performance monitor for tracking gameplay-specific metrics (e.g., enemy counts, projectile lifespan). Includes stack-trace capture for runtime errors.

### [debug_overlay.gd](../scripts/godot-debugging-profiling_debug_overlay.gd)
In-game HUD for real-time monitoring of FPS, CPU/GPU usage, and memory allocation. Supports custom telemetry fields for live tuning.


## NEVER Do

- **NEVER use `print()` without context** — Raw values like `print(x)` are difficult to track in a busy console. Always include labels: `print("Current State: ", state)`.
- **NEVER leave debug prints in production code** — Standard prints incur a performance penalty. Wrap all debug output in `if OS.is_debug_build():` blocks.
- **NEVER ignore `push_warning()` entries** — Warnings often signal impending failures or deprecated API usage. Treat them with the same priority as errors.
- **NEVER use `assert()` for critical runtime logic** — Assertions are stripped from release builds. Use `if not condition: push_error()` to ensure validation occurs in production.
- **NEVER profile in Debug Mode** — The debug template is unoptimized. For accurate performance data, always profile using a Release export or the `--release` flag.

---

## The Godot Debugger
Open via **Debug → Debugger**. Key tabs include:
- **Stack Trace**: Follow the chain of function calls leading to a crash.
- **Variables**: Inspect properties of the selected node or object while the game is paused.
- **Remote Inspect**: Switch the Scene Tree view from "Local" to "Remote" while the game is running to modify live properties and see changes in real-time.

## Custom Breakpoints
Use the `breakpoint` keyword to programmatically pause the engine at a specific line. This is superior to editor breakpoints for conditional debugging:
`if target_velocity > 1000: breakpoint`

## Performance Monitoring
Use `Performance.get_monitor()` to retrieve engine stats programmatically:
- `Performance.TIME_FPS`: Frames per second.
- `Performance.MEMORY_STATIC`: Total memory currently in use.
- `Performance.OBJECT_ORPHAN_NODE_COUNT`: Nodes that have been instantiated but not added to the tree (major memory leak source).

## Error Handling Pattern
Always check file and JSON operations for errors.
```gdscript
var file := FileAccess.open(path, FileAccess.READ)
if not file:
    push_error("Load failed: " + error_string(FileAccess.get_open_error()))
```

## Profiling Workflow
1. **Identify**: Use the **Profiler** tab to find which function is taking the most time per frame (< 16.6ms target).
2. **Isolate**: Use **Remote Inspect** to toggle nodes/scripts and verify what causes the slowdown.
3. **Optimize**: Refactor hot loops, reduce draw calls, or implement spatial hashing.

## Reference
- [Godot Docs: Debugger Panel](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/debugger_panel.html)
- [Godot Docs: Command Line Debugging](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
