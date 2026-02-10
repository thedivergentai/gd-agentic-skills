---
name: godot-autoload-architecture
description: "Expert patterns for Godot AutoLoad (singleton) architecture including global state management, scene transitions, signal-based communication, dependency injection, autoload initialization order, and anti-patterns to avoid. Use for game managers, save systems, audio controllers, or cross-scene resources. Trigger keywords: AutoLoad, singleton, GameManager, SceneTransitioner, SaveManager, global_state, autoload_order, signal_bus, dependency_injection."
---

# AutoLoad Architecture

AutoLoads are Godot's singleton pattern, allowing scripts to be globally accessible throughout the project lifecycle. This skill guides implementing robust, maintainable singleton architectures.

## NEVER Do

- **NEVER access AutoLoads in `_init()`** — AutoLoads aren't guaranteed to exist yet during _init(). Use `_ready()` or `_enter_tree()` instead.
- **NEVER create circular dependencies** — If GameManager depends on SaveManager and SaveManager depends on GameManager, initialization deadlocks. Use signals or dependency injection.
- **NEVER store scene-specific state in AutoLoads** — AutoLoads persist across scene changes. Storing temporary state (current enemy count, UI state) causes leaks. Reset in `_ready()`.
- **NEVER use AutoLoads for everything** — Over-reliance creates "God objects" and tight coupling. Limit to 5-10 AutoLoads max. Use scene trees for local logic.
- **NEVER assume AutoLoad initialization order** — AutoLoads initialize top-to-bottom in Project Settings. If order matters, add explicit `initialize()` calls or use `@onready` carefully.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [service_locator.gd](scripts/service_locator.gd)
Service locator pattern for decoupled system access. Allows swapping implementations (e.g., MockAudioManager) without changing game code.

### [stateless_bus.gd](scripts/stateless_bus.gd)
Stateless signal bus pattern. Domain-specific signals (player_health_changed, level_completed) without storing state. The bus is a post office, not a warehouse.

### [autoload_initializer.gd](scripts/autoload_initializer.gd)
Manages explicit initialization order and dependency injection to avoid circular dependencies.

> **Do NOT Load** service_locator.gd unless implementing dependency injection patterns.


---

## When to Use AutoLoads

**Good Use Cases:**
- **Game Managers**: PlayerManager, GameManager, LevelManager
- **Global State**: Score, inventory, player stats
- **Scene Transitions**: SceneTransitioner for loading/unloading scenes
- **Audio Management**: Global music/SFX controllers
- **Save/Load Systems**: Persistent data management

**Avoid AutoLoads For:**
- Scene-specific logic (use scene trees instead)
- Temporary state (use signals or direct references)
- Over-architecting simple projects

## Implementation Pattern

### Step 1: Create the Singleton Script

**Example: GameManager.gd**
```gdscript
extends Node

# Signals for global events
signal game_started
signal game_paused(is_paused: bool)
signal player_died

# Global state
var score: int = 0
var current_level: int = 1
var is_paused: bool = false

func _ready() -> void:
    # Initialize autoload state
    print("GameManager initialized")

func start_game() -> void:
    score = 0
    current_level = 1
    game_started.emit()

func pause_game(paused: bool) -> void:
    is_paused = paused
    get_tree().paused = paused
    game_paused.emit(paused)

func add_score(points: int) -> void:
    score += points
```

### Step 2: Register as AutoLoad

**Project → Project Settings → AutoLoad**

1. Click the folder icon, select `game_manager.gd`
2. Set Node Name: `GameManager` (PascalCase convention)
3. Enable if needed globally
4. Click "Add"

**Verify in `project.godot`:**
```ini
[autoload]
GameManager="*res://autoloads/game_manager.gd"
```

The `*` prefix makes it active immediately on startup.

### Step 3: Access from Any Script

```gdscript
extends Node2D

func _ready() -> void:
    # Access the singleton
    GameManager.connect("game_paused", _on_game_paused)
    GameManager.start_game()

func _on_button_pressed() -> void:
    GameManager.add_score(100)

func _on_game_paused(is_paused: bool) -> void:
    print("Game paused: ", is_paused)
```

## Best Practices

### 1. Use Static Typing
```gdscript
# ✅ Good
var score: int = 0

# ❌ Bad
var score = 0
```

### 2. Emit Signals for State Changes
```gdscript
# ✅ Good - allows decoupled listeners
signal score_changed(new_score: int)

func add_score(points: int) -> void:
    score += points
    score_changed.emit(score)

# ❌ Bad - tight coupling
func add_score(points: int) -> void:
    score += points
    ui.update_score(score)  # Don't directly call UI
```

### 3. Organize AutoLoads by Feature
```
res://autoloads/
    game_manager.gd
    audio_manager.gd
    scene_transitioner.gd
    save_manager.gd
```

### 4. Scene Transitioning Pattern
```gdscript
# scene_transitioner.gd
extends Node

signal scene_changed(scene_path: String)

func change_scene(scene_path: String) -> void:
    # Fade out effect (optional)
    await get_tree().create_timer(0.3).timeout
    get_tree().change_scene_to_file(scene_path)
    scene_changed.emit(scene_path)
```

## Common Patterns

### Game State Machine
```gdscript
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

var current_state: GameState = GameState.MENU

func change_state(new_state: GameState) -> void:
    current_state = new_state
    match current_state:
        GameState.MENU:
            # Load menu
            pass
        GameState.PLAYING:
            get_tree().paused = false
        GameState.PAUSED:
            get_tree().paused = true
        GameState.GAME_OVER:
            # Show game over screen
            pass
```

### Resource Preloading
```gdscript
# Preload heavy resources once
const PLAYER_SCENE := preload("res://scenes/player.tscn")
const EXPLOSION_EFFECT := preload("res://effects/explosion.tscn")

func spawn_player(position: Vector2) -> Node2D:
    var player := PLAYER_SCENE.instantiate()
    player.global_position = position
    return player
```

## Testing AutoLoads

Since AutoLoads are always loaded, **avoid heavy initialization in `_ready()`**. Use lazy initialization or explicit init functions:

```gdscript
var _initialized: bool = false

func initialize() -> void:
    if _initialized:
        return
    _initialized = true
    # Heavy setup here
```

## Reference
- [Godot Docs: Singletons (AutoLoad)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
- [Best Practices: Scene Organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
