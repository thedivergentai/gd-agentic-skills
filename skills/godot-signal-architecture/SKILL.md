---
name: godot-signal-architecture
description: "Expert blueprint for signal-driven architecture using \"Signal Up, Call Down\" pattern for loose coupling. Covers typed signals, signal chains, one-shot connections, and AutoLoad event buses. Use when implementing event systems OR decoupling nodes. Keywords signal, emit, connect, CONNECT_ONE_SHOT, CONNECT_REFERENCE_COUNTED, event bus, AutoLoad, decoupling."
---

# Signal Architecture

Signal Up/Call Down pattern, typed signals, and event buses define decoupled, maintainable architectures.

## Available Scripts

### [global_event_bus.gd](scripts/global_event_bus.gd)
Expert AutoLoad event bus with typed signals and connection management.

### [signal_debugger.gd](scripts/signal_debugger.gd)
Runtime signal connection analyzer. Shows all connections in scene hierarchy.

### [signal_spy.gd](scripts/signal_spy.gd)
Testing utility for observing signal emissions with count tracking and history.

> **MANDATORY - For Event Bus**: Read global_event_bus.gd before implementing cross-scene communication.


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

## Advanced Patterns

### Pattern 5: Signal Chains

```gdscript
# enemy.gd
signal died(score_value: int)

func _on_health_depleted() -> void:
    died.emit(100)
    queue_free()

# combat_manager.gd
func _ready() -> void:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        enemy.died.connect(_on_enemy_died)

func _on_enemy_died(score_value: int) -> void:
    GameManager.add_score(score_value)
    Events.enemy_killed.emit()
```

### Pattern 6: One-Shot Connections

For single-use signal connections:

```gdscript
# Connect with CONNECT_ONE_SHOT flag
timer.timeout.connect(_on_timer_timeout, CONNECT_ONE_SHOT)

func _on_timer_timeout() -> void:
    print("This only fires once")
    # Connection automatically removed
```

### Pattern 7: Custom Signal Arguments

```gdscript
# item.gd
signal picked_up(item_data: Dictionary)

func _on_player_enter() -> void:
    picked_up.emit({
        "name": item_name,
        "type": item_type,
        "value": item_value,
        "icon": item_icon
    })

# inventory.gd
func _on_item_picked_up(item_data: Dictionary) -> void:
    add_item(
        item_data.name,
        item_data.type,
        item_data.value
    )
```

## Best Practices

### 1. Descriptive Signal Names

```gdscript
# ✅ Good
signal button_pressed()
signal enemy_defeated(enemy_type: String)
signal animation_finished(animation_name: String)

# ❌ Bad
signal pressed()
signal done()
signal finished()
```

### 2. Avoid Circular Dependencies

```gdscript
# ❌ BAD: A signals to B, B signals back to A
# A.gd
signal data_requested
func _ready():
    B.data_ready.connect(_on_data_ready)
    data_requested.emit()

# B.gd
signal data_ready
func _ready():
    A.data_requested.connect(_on_data_requested)

# ✅ GOOD: Use a mediator (parent or AutoLoad)
# Parent.gd
func _ready():
    A.data_requested.connect(_on_A_data_requested)
    B.data_ready.connect(_on_B_data_ready)
```

### 3. Disconnect Signals When Nodes Are Freed

```gdscript
func _ready() -> void:
    player.died.connect(_on_player_died)

func _exit_tree() -> void:
    if player and player.died.is_connected(_on_player_died):
        player.died.disconnect(_on_player_died)
```

**Or use automatic cleanup:**
```gdscript
# Signal auto-disconnects when this node is freed
player.died.connect(_on_player_died, CONNECT_REFERENCE_COUNTED)
```

### 4. Group Related Signals

```gdscript
# ✅ Good organization
# Combat signals
signal health_changed(current: int, max: int)
signal died()
signal respawned()

# Movement signals
signal jumped()
signal landed()
signal direction_changed(direction: Vector2)

# Inventory signals
signal item_added(item: Dictionary)
signal item_removed(item: Dictionary)
signal inventory_full()
```

## Testing Signals

```gdscript
func test_health_signal() -> void:
    var signal_emitted := false
    var received_health := 0
    
    player.health_changed.connect(
        func(current: int, _max: int):
            signal_emitted = true
            received_health = current
    )
    
    player.health = 50
    assert(signal_emitted, "Signal was not emitted")
    assert(received_health == 50, "Health value incorrect")
```

## Common Gotchas

**Issue**: Signal not firing
- **Check**: Is the signal spelled correctly when connecting?
- **Check**: Is the emitting code path actually being executed?
- **Check**: Use `print()` before `emit()` to verify

**Issue**: Signal firing multiple times
- **Cause**: Multiple connections to the same signal
- **Solution**: Check connections or use `CONNECT_ONE_SHOT`

**Issue**: "Attempt to call function on a null instance"
- **Cause**: Node was freed but signal still connected
- **Solution**: Disconnect in `_exit_tree()` or use `CONNECT_REFERENCE_COUNTED`

## Reference
- [Godot Docs: Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
- [Best Practices: Signals Up, Calls Down](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
