> [!NOTE]
> **Resource Context**: This module provides expert patterns for **GDScript Mastery**. Accessed via Godot Master.

# GDScript Mastery

Expert best practices for writing performant, maintainable, and idiomatic GDScript 2.0.

## Available Scripts

### [advanced_lambdas.gd](../scripts/gdscript_mastery_advanced_lambdas.gd)
Demonstrates higher-order functions: using `filter` and `map` with lambdas, factory functions that return `Callables`, and typed array compositions.

### [type_checker.gd](../scripts/gdscript_mastery_type_checker.gd)
Utility to scan your workspace for missing static type hints. Use this to enforce a strict typing standard across the project.

### [performance_analyzer.gd](../scripts/gdscript_mastery_performance_analyzer.gd)
Identifies performance anti-patterns such as `get_node()` calls inside hot loops and expensive string concatenations.

### [signal_architecture_validator.gd](../scripts/gdscript_mastery_signal_architecture_validator.gd)
Enforces the "Signal Up, Call Down" architecture by detecting illegal `get_parent()` calls and untyped signal declarations.


## NEVER Do

- **NEVER use dynamic typing in performance-critical paths** — `var x = 5` is significantly slower than `var x: int = 5`. Static typing allows the GDScript compiler to optimize execution.
- **NEVER use "Call Up" (Parent access)** — Children should never call methods on their parents. Always use "Signal Up, Call Down": children emit signals, parents handle them.
- **NEVER call `get_node()` or `$` inside `_process()`** — This lookup is expensive. Cache references in `@onready` variables during initialization.
- **NEVER access dictionary keys directly (`dict["key"]`)** — If the key is missing, the game crashes. Use `dict.get("key", default_value)` for safe, crash-proof lookups.
- **NEVER skip the `class_name` declaration** — Without a class name, you cannot use the script as a type hint in other files, making refactoring much more difficult.

---

## Static Typing Standards
Every function should have a return type (`-> void`, `-> int`). Every variable should have a colon-defined type. 
`var player_speed: float = 300.0`

## Signal Architecture
Signals are the "glue" of a Godot project. 
- Define them at the top of the script.
- Type your signal parameters: `signal item_picked_up(item: ItemResource)`.
- Connect signals in `_ready()` or via the editor to maintain clear event flow.

## Scene Unique Names
For complex UI, use the `%NodeName` syntax. Right-click a node in the scene tree and select "Access as Scene Unique Name" to make it globally accessible within that scene's script without relying on fragile path strings.

## Style Guide: Script Layout
1. `extends`
2. `class_name`
3. Signals / Enums / Constants
4. `@export` / `@onready` / Public variables
5. `_ready()` / `_process()` / `_physics_process()`
6. Public methods
7. Private methods (prefixed with `_`)

## Reference
- [Godot Docs: GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot Docs: Static Typing in GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html)
