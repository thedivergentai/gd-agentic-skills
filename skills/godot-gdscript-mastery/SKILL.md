---
name: godot-gdscript-mastery
description: "Expert GDScript best practices including static typing (var x: int, func returns void), signal architecture (signal up call down), unique node access (%NodeName, @onready), script structure (extends, class_name, signals, exports, methods), and performance patterns (dict.get with defaults, avoid get_node in loops). Use for code review, refactoring, or establishing project standards. Trigger keywords: static_typing, signal_architecture, unique_nodes, @onready, class_name, signal_up_call_down, gdscript_style_guide."
---

# GDScript Mastery

Expert guidance for writing performant, maintainable GDScript following official Godot standards.

## NEVER Do

- **NEVER use dynamic typing for performance-critical code** — `var x = 5` is 20-40% slower than `var x: int = 5`. Type everything.
- **NEVER call parent methods from children ("Call Up")** — Use "Signal Up, Call Down". Children emit signals, parents call child methods.
- **NEVER use `get_node()` in `_process()` or `_physics_process()`** — Caches with `@onready var sprite = $Sprite`. get_node() is slow in loops.
- **NEVER access dictionaries without `.get()` default** — `dict["key"]` crashes if missing. Use `dict.get("key", default)` for safety.
- **NEVER skip `class_name` for reusable scripts** — Without `class_name`, you can't use as type hints (`var item: Item`). Makes code harder to maintain.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [advanced_lambdas.gd](scripts/advanced_lambdas.gd)
Higher-order functions in GDScript: filter/map with lambdas, factory functions returning Callables, typed array godot-composition, and static utility methods.

### [type_checker.gd](scripts/type_checker.gd)
Scans codebase for missing type hints. Run before releases to enforce static typing standards.

### [performance_analyzer.gd](scripts/performance_analyzer.gd)
Detects performance anti-patterns: get_node() in loops, string concat, unsafe dict access.

### [signal_architecture_validator.gd](scripts/signal_architecture_validator.gd)
Enforces "Signal Up, Call Down" pattern. Detects get_parent() calls and untyped signals.

> **Do NOT Load** performance_analyzer.gd unless profiling hot paths or optimizing frame rates.


---

## Core Directives

### 1. Strong Typing
Always use static typing. It improves performance and catches bugs early.
**Rule**: Prefer `var x: int = 5` over `var x = 5`.
**Rule**: Always specify return types for functions: `func _ready() -> void:`.

### 2. Signal Architecture
- **Connect in `_ready()`**: Preferably connect signals in code to maintain visibility, rather than just in the editor.
- **Typed Signals**: Define signals with types: `signal item_collected(item: ItemResource)`.
- **Pattern**: "Signal Up, Call Down". Children should never call methods on parents; they should emit signals instead.

### 3. Node Access
- **Unique Names**: Use `%UniqueNames` for nodes that are critical to the script's logic.
- **Onready Overrides**: Prefer `@onready var sprite = %Sprite2D` over calling `get_node()` in every function.

### 4. Code Structure
Follow the standard Godot script layout:
1. `extends`
2. `class_name`
3. `signals` / `enums` / `constants`
4. `@export` / `@onready` / `properties`
5. `_init()` / `_ready()` / `_process()`
6. Public methods
7. Private methods (prefixed with `_`)

## Common "Architect" Patterns

### The "Safe" Dictionary Lookup
Avoid `dict["key"]` if you aren't 100% sure it exists. Use `dict.get("key", default)`.

### Scene Unique Nodes
When building complex UI, always toggle "Access as Scene Unique Name" on critical nodes (Labels, Buttons) and access them via `%Name`.

## Reference
- Official Docs: `tutorials/scripting/gdscript/gdscript_styleguide.rst`
- Official Docs: `tutorials/best_practices/logic_preferences.rst`


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
