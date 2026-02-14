> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Signal Architecture**. Accessed via Godot Master.

# Signal Architecture

Signal Up/Call Down pattern, typed signals, and event buses define decoupled, maintainable architectures.

## Available Scripts

### [global_event_bus.gd](../scripts/godot-signal-architecture_global_event_bus.gd)
Expert AutoLoad event bus with typed signals and connection management.

### [signal_debugger.gd](../scripts/godot-signal-architecture_signal_debugger.gd)
Runtime signal connection analyzer. Shows all connections in scene hierarchy.

### [signal_spy.gd](../scripts/godot-signal-architecture_signal_spy.gd)
Testing utility for observing signal emissions with count tracking and history.

> **MANDATORY - For Event Bus**: Read [global_event_bus.gd](../scripts/godot-signal-architecture_global_event_bus.gd) before implementing cross-scene communication.


## NEVER Do in Signal Architecture

- **NEVER create circular signal dependencies** — A signals to B, B signals back to A? Infinite loops + stack overflow. Use mediator (parent OR AutoLoad) to break cycle.
- **NEVER skip signal typing** — `signal moved` without types? No autocomplete OR type safety. Use `signal moved(direction: Vector2)` for editor support.
- **NEVER forget to disconnect signals** — Node freed but signal still connected? "Attempt to call on null instance" error. Disconnect in `_exit_tree()` OR use `CONNECT_REFERENCE_COUNTED`.
- **NEVER connect signals in _ready() for dynamic nodes** — Enemy spawned after level load? Signals not connected. Connect when instantiating OR use groups + `await` pattern.
- **NEVER use signals for parent→child** — Parent signaling to child breaks encapsulation. CALL DOWN directly: `child.method()`. Reserve signals for child→parent communication.
- **NEVER emit signals with side effects** — `died.emit()` calls `queue_free()` inside? Listeners can't respond before node freed. Emit FIRST, then cleanup.
- **NEVER use string-based signal names** — `connect("heath_chnaged", ...)` typo = silent failure. Use direct reference: `player.health_changed.connect(...)`.

---

**Use Signals For:**
- UI button presses → game logic
- Player death → game over screen
- Item collected → inventory update
- Enemy killed → score update
- Cross-scene communication via AutoLoad

**Use Direct Calls For:**
- Parent controlling child behavior
- Accessing child properties
- Simple, local interactions

## Implementation Patterns

### Pattern 1: Define Typed Signals

```gdscript
extends CharacterBody2D

# ✅ Good - typed signals (Godot 4.x)
signal health_changed(new_health: int, max_health: int)
signal died()
signal item_collected(item_name: String, item_type: int)

# ❌ Bad - untyped signals
signal health_changed
signal died
```

### Pattern 2: Emit Signals on State Changes

```gdscript
# player.gd
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died()

var health: int = 100:
    set(value):
        health = clamp(value, 0, max_health)
        health_changed.emit(health, max_health)
        if health <= 0:
            died.emit()

var max_health: int = 100

func take_damage(amount: int) -> void:
    health -= amount  # Triggers setter, which emits signal
```

### Pattern 3: Connect Signals in Parent

```gdscript
# game.gd (parent)
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var ui: Control = $UI

func _ready() -> void:
    # Connect child signals
    player.health_changed.connect(_on_player_health_changed)
    player.died.connect(_on_player_died)

func _on_player_health_changed(current: int, maximum: int) -> void:
    # Call down to UI
    ui.update_health_bar(current, maximum)

func _on_player_died() -> void:
    # Orchestrate game over
    ui.show_game_over()
    get_tree().paused = true
```

### Pattern 4: Global Signals via AutoLoad

For cross-scene communication:

```gdscript
# events.gd (AutoLoad)
extends Node

signal level_completed(level_number: int)
signal player_spawned(player: Node2D)
signal boss_defeated(boss_name: String)

# Any script can emit:
Events.level_completed.emit(3)

# Any script can listen:
Events.level_completed.connect(_on_level_completed)
```

## Best Practices

### 1. Descriptive Signal Names
Use specific names like `button_pressed()` or `enemy_defeated()` instead of generic ones like `pressed()` or `done()`.

### 2. Avoid Circular Dependencies
Use a mediator (parent or AutoLoad) to bridge communication between two nodes that need each other's data.

### 3. Disconnect Signals When Nodes Are Freed
Disconnect signals manually in `_exit_tree()` or use the `CONNECT_REFERENCE_COUNTED` flag for automatic management.

### 4. Group Related Signals
Keep signals organized by domain (Combat, Movement, Inventory).

## Testing Signals
Test signals by connecting an anonymous function that sets a flag or tracks parameters during the test execution.

## Reference
- [Godot Docs: Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
- [Best Practices: Signals Up, Calls Down](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html)
