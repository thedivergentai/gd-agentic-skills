---
name: godot-project-templates
description: "Expert blueprint for genre-specific project boilerplates (2D platformer, top-down RPG, 3D FPS) including directory structures, AutoLoad patterns, and core systems. Use when bootstrapping new projects or migrating architecture. Keywords project templates, boilerplate, 2D platformer, RPG, FPS, AutoLoad, scene structure."
---

# Project Templates

Genre-specific scaffolding, AutoLoad patterns, and modular architecture define rapid prototyping.

## Available Scripts

### [base_game_manager.gd](scripts/base_game_manager.gd)
Expert AutoLoad template for game state management (pause, scene transitions, scoring).

## NEVER Do in Project Templates

- **NEVER hardcode scene paths** — `get_tree().change_scene_to_file("res://levels/level_1.tscn")` in 20 places? Nightmare refactoring. Use AutoLoad + constants OR scene registry.
- **NEVER forget AutoLoad registration** — Template includes `game_manager.gd` but not in Project Settings? Script won't load. MUST add to Project → AutoLoad.
- **NEVER use `get_tree().paused` without groups** — Pausing entire tree = pause menu also freezes. Use process mode groups (`PROCESS_MODE_PAUSABLE` vs `PROCESS_MODE_ALWAYS`).
- **NEVER skip Input.MOUSE_MODE_CAPTURED in FPS** — FPS template without mouse capture = cursor visible during gameplay. Set in player `_ready()`.
- **NEVER copy-paste templates as-is** — Using platformer template for RPG? Leads to architectural debt. UNDERSTAND the structure, then adapt.

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
- [GDSkills godot-project-foundations](file:///D:/Development/GDSkills/skills/godot-project-foundations/SKILL.md)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
