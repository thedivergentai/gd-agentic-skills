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
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [performance_plotter.gd](scripts/performance_plotter.gd)
Custom Performance monitors for gameplay metrics (projectile/enemy count). Includes automated error state capture with stack traces and memory stats.

### [debug_overlay.gd](scripts/debug_overlay.gd)
In-game debug UI with real-time FPS, memory, orphan nodes, and custom metrics.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)
