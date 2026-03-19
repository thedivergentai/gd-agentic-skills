---
name: godot-debugging-profiling
description: "Expert debugging workflows including print debugging (push_warning, push_error, assert), breakpoints (conditional breakpoints), Godot Debugger (stack trace, variables, remote debug), profiler (time profiler, memory monitor), error handling patterns, and performance optimization. Use for bug fixing, performance tuning, or development diagnostics. Trigger keywords: breakpoint, print_debug, push_error, assert, profiler, remote_debug, memory_leak, orphan_nodes, Performance.get_monitor."
---

# Debugging & Profiling

Expert guidance for finding and fixing bugs efficiently with Godot's debugging tools.

## NEVER Do

- **NEVER use `print()` without descriptive context** — `print(value)` is useless. Use `print("Player health:", health)` with labels.
- **NEVER leave debug prints in release builds** — Wrap in `if OS.is_debug_build()` or use custom DEBUG const. Prints slow down release.
- **NEVER ignore `push_warning()` messages** — Warnings indicate potential bugs (null refs, deprecated APIs). Fix them before they become errors.
- **NEVER use `assert()` for runtime validation in release** — Asserts are disabled in release builds. Use `if not condition: push_error()` for runtime checks.
- **NEVER profile in debug mode** — Debug builds are 5-10x slower. Always profile with release exports or `--release` flag.
- **NEVER assume `Engine.capture_script_backtraces(true)` is cheap** — Capturing locals allocates significant memory and can prevent objects from being deallocated, causing artificial leaks [19].
- **NEVER call `push_error()` or `print()` inside a custom `Logger._log_message` override** — This causes infinite recursion and crashes as the logger intercepts its own output [20].
- **NEVER leave the Visual Profiler running during gameplay tests** — Continuous polling degrades framerates significantly, invalidating actual performance metrics [21].
- **NEVER rely on `OS.get_ticks_msec()` for microbenchmarking** — Milliseconds lack precision for logic timing; ALWAYS use `Time.get_ticks_usec()` for microsecond precision [22].
- **NEVER assume `OBJECT_ORPHAN_NODE_COUNT` works in production** — This monitor is strictly debug-only; it safely returns 0 in release builds, potentially hiding leaks [23].
- **NEVER benchmark with V-Sync enabled** — V-Sync throttles metrics to the monitor refresh rate, masking the true CPU/GPU processing overhead [24].
- **NEVER leave `print_stack()` or `print_debug()` in release builds** — These are often stripped or useless outside the debugger. Use structured logging for production [25].
- **NEVER strip debugging symbols if using external C++ profilers** — Stripping destroys call stack readability for external tools like Perfetto or VerySleepy [26].
- **NEVER forget to unregister an `EditorDebuggerPlugin` in `_exit_tree()`** — Failing to clean up leaves "ghost" connections in the engine's debugging loop [27].
- **NEVER trust the Visual Profiler on macOS when using the Compatibility renderer** — Platform-specific driver limitations severely restrict OpenGL profiling accuracy on macOS [28].
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [high_precision_benchmarker.gd](../scripts/debugging_profiling_high_precision_benchmarker.gd)
Micrometer-precision execution timing using `Time.get_ticks_usec()`, essential for identifying CPU micro-bottlenecks.

### [orphan_node_detector.gd](../scripts/debugging_profiling_orphan_node_detector.gd)
Automated detection and logging of "Orphan Nodes" (nodes removed from tree but not freed) using internal Performance monitors.

### [advanced_backtrace_recorder.gd](../scripts/debugging_profiling_advanced_backtrace_recorder.gd)
Capturing detailed script backtraces programmatically, including local variable snapshots for deep crash reporting.

### [engine_error_interceptor.gd](../scripts/debugging_profiling_engine_error_interceptor.gd)
Intercepting underlying C++ engine errors and piping them to custom backend logs or analytics services.

### [custom_editor_monitor.gd](../scripts/debugging_profiling_custom_editor_monitor.gd)
Exposing game-specific performance metrics (AI counts, bullet physics) directly to the Godot Editor's Debugger > Monitors tab.

### [debugger_tab_plugin.gd](../scripts/debugging_profiling_debugger_tab_plugin.gd)
Project-specific debugger extensions that inject custom visual tabs and data into the Godot bottom panel.

### [thread_safe_logger.gd](../scripts/debugging_profiling_thread_safe_logger.gd)
Mutext-locked logger subclass for thread-safe writing of logs from worker threads to external files.

### [custom_debug_draw.gd](../scripts/debugging_profiling_custom_debug_draw.gd)
Pro-level visualization patterns for non-visual data like pathfinding nodes, physics raycasts, and local AI influence maps.

### [break_on_condition.gd](../scripts/debugging_profiling_break_on_condition.gd)
Hardcoded breakpoint triggers for halting execution on invalid logic states in a team-agnostic manner.

### [remote_debug_console.gd](../scripts/debugging_profiling_remote_debug_console.gd)
In-game command console for debugging mobile and console builds where standard terminal output is inaccessible.

> **Do NOT Load** debug_overlay.gd in release builds - wrap usage in `if OS.is_debug_build()`.


---

## Print Debugging

```gdscript
# Basic print
print("Value: ", some_value)

# Formatted print
print("Player at %s with health %d" % [position, health])

# Print with caller info
print_debug("Debug info here")

# Warning (non-fatal)
push_warning("This might be a problem")

# Error (non-fatal)
push_error("Something went wrong!")

# Assert (fatal in debug)
assert(health > 0, "Health cannot be negative!")
```

## Breakpoints

**Set Breakpoint:**
- Click line number gutter in script editor
- Or use `breakpoint` keyword:

```gdscript
func suspicious_function() -> void:
    breakpoint  # Execution stops here
    var result := calculate_something()
```

## Debugger Panel

**Debug → Debugger** (Ctrl+Shift+D)

Tabs:
- **Stack Trace**: Call stack when paused
- **Variables**: Inspect local/member variables
- **Breakpoints**: Manage all breakpoints
- **Errors**: Runtime errors and warnings

## Remote Debug

**Debug running game:**
1. Run project (F5)
2. Debug → Remote Debug → Select running instance
3. Inspect live game state

## Common Debugging Patterns

### Null Reference

```gdscript
# ❌ Crash: null reference
$NonExistentNode.do_thing()

# ✅ Safe: check first
var node := get_node_or_null("MaybeExists")
if node:
    node.do_thing()
```

### Track State Changes

```gdscript
var _health: int = 100

var health: int:
    get:
        return _health
    set(value):
        print("Health changed: %d → %d" % [_health, value])
        print_stack()  # Show who changed it
        _health = value
```

### Visualize Raycasts

```gdscript
func _draw() -> void:
    if Engine.is_editor_hint():
        draw_line(Vector2.ZERO, ray_direction * ray_length, Color.RED, 2.0)
```

### Debug Draw in 3D

```gdscript
# Use DebugDraw addon or create debug meshes
func debug_draw_sphere(pos: Vector3, radius: float) -> void:
    var mesh := SphereMesh.new()
    mesh.radius = radius
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    instance.global_position = pos
    add_child(instance)
```

## Error Handling

```gdscript
# Handle file errors
func load_save() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        push_warning("No save file found")
        return {}
    
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        push_error("Failed to open save: %s" % FileAccess.get_open_error())
        return {}
    
    var json := JSON.new()
    var error := json.parse(file.get_as_text())
    if error != OK:
        push_error("JSON parse error: %s" % json.get_error_message())
        return {}
    
    return json.data
```

## Profiler

**Debug → Profiler** (F3)

### Time Profiler
- Shows function execution times
- Identify slow functions
- Target: < 16.67ms per frame (60 FPS)

### Monitor
- FPS, physics, memory
- Object count
- Draw calls

## Common Performance Issues

### Issue: Low FPS

```gdscript
# Check in _process
func _process(delta: float) -> void:
    print(Engine.get_frames_per_second())  # Monitor FPS
```

### Issue: Memory Leaks

```gdscript
# Check with print
func _exit_tree() -> void:
    print("Node freed: ", name)

# Use groups to track
add_to_group("tracked")
print("Active objects: ", get_tree().get_nodes_in_group("tracked").size())
```

### Issue: Orphaned Nodes

```gdscript
# Check for orphans
func check_orphans() -> void:
    print("Orphan nodes: ", Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
```

## Debug Console

```gdscript
# Runtime debug console
var console_visible := false

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.keycode == KEY_QUOTELEFT:
        console_visible = not console_visible
        $DebugConsole.visible = console_visible
```

## Best Practices

### 1. Use Debug Flags

```gdscript
const DEBUG := true

func debug_log(message: String) -> void:
    if DEBUG:
        print("[DEBUG] ", message)
```

### 2. Conditional Breakpoints

```gdscript
# Only break on specific condition
if player.health <= 0:
    breakpoint
```

### 3. Scene Tree Inspector

```
Debug → Remote Debug → Inspect scene tree
See live node hierarchy
```

## Reference
- [Godot Docs: Debugger](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/debugger_panel.html)


### Related
- Master Skill: [godot-master](../SKILL.md)
