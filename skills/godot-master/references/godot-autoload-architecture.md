> [!NOTE]
> **Resource Context**: This module provides expert patterns for **AutoLoad Architecture**. Accessed via Godot Master.

# AutoLoad Architecture

AutoLoads are Godot's singleton pattern, allowing scripts to be globally accessible throughout the project lifecycle. This module guides implementing robust, maintainable singleton architectures.

## NEVER Do

- **NEVER access AutoLoads in `_init()`** — AutoLoads aren't guaranteed to exist yet during _init(). Use `_ready()` or `_enter_tree()` instead.
- **NEVER create circular dependencies** — If GameManager depends on SaveManager and SaveManager depends on GameManager, initialization deadlocks. Use signals or dependency injection.
- **NEVER store scene-specific state in AutoLoads** — AutoLoads persist across scene changes. Storing temporary state (current enemy count, UI state) causes leaks. Reset in `_ready()`.
- **NEVER use AutoLoads for everything** — Over-reliance creates "God objects" and tight coupling. Limit to 5-10 AutoLoads max. Use scene trees for local logic.
- **NEVER assume AutoLoad initialization order** — AutoLoads initialize top-to-bottom in Project Settings. If order matters, add explicit `initialize()` calls or use `@onready` carefully.

---

## Available Scripts

### [service_locator.gd](../scripts/godot-autoload-architecture_service_locator.gd)
Service locator pattern for decoupled system access. Allows swapping implementations (e.g., MockAudioManager) without changing game code.

### [stateless_bus.gd](../scripts/godot-autoload-architecture_stateless_bus.gd)
Stateless signal bus pattern. Domain-specific signals (player_health_changed, level_completed) without storing state.

### [autoload_initializer.gd](../scripts/godot-autoload-architecture_autoload_initializer.gd)
Manages explicit initialization order and dependency injection to avoid circular dependencies.

> **Do NOT Load** [service_locator.gd](../scripts/godot-autoload-architecture_service_locator.gd) unless implementing dependency injection patterns.


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
Ensure all global variables and signals are strictly typed for autocomplete and safety.

### 2. Emit Signals for State Changes
Allow decoupled listeners (UI, Achievements, Audio) to respond to global events without tight coupling in the manager.

### 3. Organize AutoLoads by Feature
Keep your `res://autoloads/` folder clean with specific managers rather than one massive script.

## Reference
- [Godot Docs: Singletons (AutoLoad)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
- [Best Practices: Scene Organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html)
