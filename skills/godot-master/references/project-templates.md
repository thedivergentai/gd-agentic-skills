---
name: godot-project-templates
description: "Expert blueprint for genre-specific project boilerplates (2D platformer, top-down RPG, 3D FPS) including directory structures, AutoLoad patterns, and core systems. Use when bootstrapping new projects or migrating architecture. Keywords project templates, boilerplate, 2D platformer, RPG, FPS, AutoLoad, scene structure."
---

# Project Templates

Genre-specific scaffolding, AutoLoad patterns, and modular architecture define rapid prototyping.

## Available Scripts

### [base_game_manager.gd](../scripts/project_templates_base_game_manager.gd)
Expert AutoLoad template for game state management.

### [base_level.gd](../scripts/project_templates_base_level.gd)
Abstract base class for all loaded levels with structured lifecycle hooks.

### [base_actor.gd](../scripts/project_templates_base_actor.gd)
Expert foundation for all gameplay agents (Player, NPC, Enemies).

### [base_menu.gd](../scripts/project_templates_base_menu.gd)
UI foundation for focus persistence, animations, and input blocking.

### [subsystem_locator.gd](../scripts/project_templates_subsystem_locator.gd)
Decoupled alternative to monolithic managers for modular registration.

### [multi_platform_input.gd](../scripts/project_templates_multi_platform_input.gd)
Template-driven Input Mapping for hardware-aware profile overrides.

### [platform_feature_config.gd](../scripts/project_templates_platform_feature_config.gd)
Conditional platform logic using Godot Feature Tags.

### [scene_state_machine.gd](../scripts/project_templates_scene_state_machine.gd)
Node-based State Machine boilerplate for visual state logic.

### [state_machine_node.gd](../scripts/project_templates_state_machine_node.gd)
Abstract state node foundation for specialized state components.

### [accessibility_tts_manager.gd](../scripts/project_templates_accessibility_tts_manager.gd)
Accessibility & Localization foundation using native TTS API.

### [level_steamer_manager.gd](../scripts/project_templates_level_steamer_manager.gd)
Background level-loading template using `load_threaded_request`.

## NEVER Do (Expert Anti-Patterns)

### Directory & Scaffolding
- **NEVER hardcode scene paths** — `get_tree().change_scene_to_file("res://levels/level_1.tscn")` in 20 places? Nightmare refactoring. Use AutoLoad + constants OR scene registry.
- **NEVER skip .gdignore for asset folders** — Designer internal project files should never be imported into res:// directly.

### Architecture & Lifecycle
- **NEVER use `get_tree().paused` without groups** — Pausing entire tree = pause menu freezes. Use process mode `PROCESS_MODE_ALWAYS` on UI.
- **NEVER skip virtual lifecycle hooks** — In base classes, always provide `_initialize_X()` hooks instead of just `_ready()` to allow child overrides without breaking parents.
- **NEVER rely on monolithic "God" singletons** — Decouple systems using a **Signal Bus** or **Subsystem Locator**.

### Platform & UI
- **NEVER skip Input.MOUSE_MODE_CAPTURED in FPS** — Set in player `_ready()` to ensure focus.
- **NEVER use floating point constants for UI layout** — Leads to drift. Use anchors and containers.
- **NEVER ignore i18n Translation Context** — "Lead" (Metal) vs "Lead" (Action). Strictly use contexts in `translate()`.

### Performance
- **NEVER load massive levels synchronously** — Causes frame freezes. Strictly use `ResourceLoader.load_threaded_request()`.
- **NEVER copy-paste templates as-is** — Using platformer template for RPG? Leads to debt. UNDERSTAND the structure, then adapt.

---

### Directory Structure

```
my_platformer/
├── project.godot
├── autoloads/
│   ├── game_manager.gd
│   ├── audio_manager.gd
│   └── scene_transitioner.gd
├── scenes/
│   ├── main_menu.tscn
│   ├── game.tscn
│   └── pause_menu.tscn
├── entities/
│   ├── player/
│   │   ├── player.tscn
│   │   ├── player.gd
│   │   └── player_states/
│   └── enemies/
│       ├── base_enemy.gd
│       └── goblin/
├── levels/
│   ├── level_1.tscn
│   └── tilesets/
├── ui/
│   ├── hud.tscn
│   └── themes/
├── audio/
│   ├── music/
│   └── sfx/
└── resources/
    └── data/
```

### Core Scripts

**game_manager.gd:**
```gdscript
extends Node

signal game_started
signal game_paused(paused: bool)
signal level_completed

var current_level: int = 1
var score: int = 0
var is_paused: bool = false

func start_game() -> void:
    score = 0
    current_level = 1
    SceneTransitioner.change_scene("res://levels/level_1.tscn")
    game_started.emit()

func pause_game(paused: bool) -> void:
    is_paused = paused
    get_tree().paused = paused
    game_paused.emit(paused)

func complete_level() -> void:
    current_level += 1
    level_completed.emit()
```

---

## Top-Down RPG Template

### Directory Structure

```
my_rpg/
├── autoloads/
│   ├── game_data.gd
│   ├── dialogue_manager.gd
│   └── inventory_manager.gd
├── entities/
│   ├── player/
│   ├── npcs/
│   └── interactables/
├── maps/
│   ├── overworld/
│   ├── dungeons/
│   └── interiors/
├── systems/
│   ├── combat/
│   ├── dialogue/
│   ├── quests/
│   └── inventory/
├── ui/
│   ├── inventory_ui.tscn
│   ├── dialogue_box.tscn
│   └── quest_log.tscn
└── resources/
    ├── items/
    ├── quests/
    └── dialogues/
```

### Core Systems

**inventory_manager.gd:**
```gdscript
extends Node

signal item_added(item: Resource)
signal item_removed(item: Resource)

var inventory: Array[Resource] = []

func add_item(item: Resource) -> void:
    inventory.append(item)
    item_added.emit(item)

func remove_item(item: Resource) -> bool:
    if item in inventory:
        inventory.erase(item)
        item_removed.emit(item)
        return true
    return false

func has_item(item_id: String) -> bool:
    for item in inventory:
        if item.id == item_id:
            return true
    return false
```

---

## 3D FPS Template

### Directory Structure

```
my_fps/
├── autoloads/
│   ├── game_manager.gd
│   └── weapon_manager.gd
├── player/
│   ├── player.tscn
│   ├── player.gd
│   ├── camera_controller.gd
│   └── weapons/
│       ├── weapon_base.gd
│       ├── pistol/
│       └── rifle/
├── enemies/
│   ├── ai_controller.gd
│   └── soldier/
├── levels/
│   ├── level_1/
│   └── level_2/
├── ui/
│   ├── hud.tscn
│   └── crosshair.tscn
└── resources/
    ├── weapons/
    └── pickups/
```

### Player Controller

**player.gd:**
```gdscript
extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 4.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $Camera3D
@onready var weapon_holder: Node3D = $Camera3D/WeaponHolder

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity
    
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
    
    move_and_slide()
```

---

## Input Map Template

```ini
# All templates should include these actions:

[input]
move_left=Keys: A, Left, Gamepad Left
move_right=Keys: D, Right, Gamepad Right
move_up=Keys: W, Up, Gamepad Up
move_down=Keys: S, Down, Gamepad Down
jump=Keys: Space, Gamepad A
interact=Keys: E, Gamepad X
pause=Keys: Escape, Gamepad Start
ui_accept=Keys: Enter, Gamepad A
ui_cancel=Keys: Escape, Gamepad B
```

## Usage

1. Copy template structure
2. Rename project in `project.godot`
3. Register AutoLoads
4. Configure Input Map
5. Begin development

## Reference
- [GDSkills godot-project-foundations](project-foundations.md)


### Related
- Master Skill: [godot-master](../SKILL.md)
