---
name: godot-gdscript-mastery
description: "Expert GDScript best practices including static typing (var x: int, func returns void), signal architecture (signal up call down), unique node access (%NodeName, @onready), script structure (extends, class_name, signals, exports, methods), and performance patterns (dict.get with defaults, avoid get_node in loops). Use for code review, refactoring, or establishing project standards. Trigger keywords: static_typing, signal_architecture, unique_nodes, @onready, class_name, signal_up_call_down, gdscript_style_guide."
---

# GDScript Mastery

Expert guidance for writing performant, maintainable GDScript following official Godot standards.

## Available Scripts

### [typed_collections_mastery.gd](../scripts/gdscript_mastery_typed_collections_mastery.gd)
Expert performance optimization using statically typed Arrays and Dictionaries.

### [functional_lambda_logic.gd](../scripts/gdscript_mastery_functional_lambda_logic.gd)
Advanced list processing using `reduce()`, `all()`, and `any()` with clean lambda syntax.

### [safe_type_casting.gd](../scripts/gdscript_mastery_safe_type_casting.gd)
Best practices for using the `as` operator for crash-proof object identification.

### [typed_signal_definitions.gd](../scripts/gdscript_mastery_typed_signal_definitions.gd)
Enforcing type safety across script boundaries using strictly typed signal arguments.

### [callable_binding_context.gd](../scripts/gdscript_mastery_callable_binding_context.gd)
Injecting extra context into signal callbacks using `Callable.bind()`.

### [unbind_signal_args.gd](../scripts/gdscript_mastery_unbind_signal_args.gd)
Safely discarding unneeded signal arguments using `Callable.unbind()`.

### [await_sequence_manager.gd](../scripts/gdscript_mastery_await_sequence_manager.gd)
Managing complex asynchronous flows and timers using `await` without thread-blocking.

### [array_preallocation_perf.gd](../scripts/gdscript_mastery_array_preallocation_perf.gd)
Eliminating memory reallocation lag by pre-sizing large arrays with `resize()`.

### [static_var_singleton_alt.gd](../scripts/gdscript_mastery_static_var_singleton_alt.gd)
Using `static var` for global state management as an alternative to heavy Autoloads.

### [dictionary_safe_iteration.gd](../scripts/gdscript_mastery_dictionary_safe_iteration.gd)
The correct pattern for erasing dictionary keys while iterating to avoid runtime errors.

## NEVER Do in GDScript

- **NEVER use `@onready` and `@export` on the same variable** — Initialization order will cause `@onready` to overwrite the Inspector value [1].
- **NEVER modify a Dictionary's size while iterating it** — Use `dict.keys().duplicate()` or iterate a clone to safely erase elements [2, 3].
- **NEVER use string-based `connect("signal", ...)`** — Always use the Signal object syntax (`button.pressed.connect(...)`) for compile-time safety [4].
- **NEVER attempt to override non-virtual native engine methods** — Overriding `queue_free()` or `get_class()` is unsupported and will be ignored by engine callbacks [5, 6].
- **NEVER use dynamic `get_node()` or `$` inside `_process()`** — Fetching paths every frame stalls the CPU. Cache and use `@onready` [7, 8].
- **NEVER use `Parent.method()` calls** — Violates "Signal Up, Call Down". Use signals to communicate with parents.
- **NEVER use `is` followed by a hard cast** — If the type check passes but the object changes, it crashes. Use `as` and check for null.
- **NEVER use `print()` for production debugging** — Use `push_error()`, `push_warning()`, or breakpoints to ensure errors are visible in the console/logs.
- **NEVER pre-load huge resources in `_ready()`** — This causes frame stutters. Use `ResourceLoader.load_threaded_request()` for async loading.
- **NEVER use global variables in Autoloads when `static var` is sufficient** — Static variables offer better encapsulation and less project pollution [24].


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
- Master Skill: [godot-master](../SKILL.md)
