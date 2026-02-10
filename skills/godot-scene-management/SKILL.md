---
name: godot-scene-management
description: "Expert blueprint for scene loading, transitions, async (background) loading, instance management, and caching. Covers fade transitions, loading screens, dynamic spawning, and scene persistence. Use when implementing level changes OR dynamic content loading. Keywords scene, loading, transition, async, ResourceLoader, change_scene, preload, PackedScene, fade."
---

# Scene Management

Async loading, transitions, instance pooling, and caching define smooth scene workflows.

## Available Scripts

### [async_scene_manager.gd](scripts/async_scene_manager.gd)
Expert async scene loader with progress tracking, error handling, and transition callbacks.

### [scene_pool.gd](scripts/scene_pool.gd)
Object pooling for frequently spawned scenes (bullets, godot-particles, enemies).

### [scene_state_manager.gd](scripts/scene_state_manager.gd)
Preserves and restores scene state across transitions using "persist" group pattern.

> **MANDATORY - For Smooth Transitions**: Read async_scene_manager.gd before implementing loading screens.


## NEVER Do in Scene Management

- **NEVER use load() in gameplay code** — `var scene = load("res://level.tscn")` blocks entire game until loaded. Use `preload()` OR `ResourceLoader.load_threaded_request()`.
- **NEVER forget to check THREAD_LOAD_FAILED** — Async loading without status check? Silent failure = black screen. MUST handle `THREAD_LOAD_FAILED` state.
- **NEVER change scenes without cleaning up** — Active timers/tweens persist across scenes = memory leak + unexpected behavior. Stop timers, disconnect signals before transition.
- **NEVER use get_tree().change_scene_to_file() during _ready()** — Changing scene in `_ready()` = crash (scene tree locked). Use `call_deferred("change_scene")`.
- **NEVER instance scenes without null check** — `var obj = scene.instantiate()` if scene load failed? Crash. Check scene != null first.
- **NEVER forget queue_free() on dynamic instances** — Spawned 1000 enemies, all dead, but not freed? Memory leak. Use `queue_free()` OR instance pooling.

---

```gdscript
# Instant scene change
get_tree().change_scene_to_file("res://levels/level_2.tscn")

# Or with packed scene
var next_scene := load("res://levels/level_2.tscn")
get_tree().change_scene_to_packed(next_scene)
```

## Scene Transition with Fade

```gdscript
# scene_transitioner.gd (AutoLoad)
extends CanvasLayer

signal transition_finished

func change_scene(scene_path: String) -> void:
    # Fade out
    $AnimationPlayer.play("fade_out")
    await $AnimationPlayer.animation_finished
    
    # Change scene
    get_tree().change_scene_to_file(scene_path)
    
    # Fade in
    $AnimationPlayer.play("fade_in")
    await $AnimationPlayer.animation_finished
    
    transition_finished.emit()

# Usage:
SceneTransitioner.change_scene("res://levels/level_2.tscn")
await SceneTransitioner.transition_finished
```

## Async (Background) Loading

```gdscript
extends Node

var loading_status: int = 0
var progress := []

func load_scene_async(path: String) -> void:
    ResourceLoader.load_threaded_request(path)
    
    while true:
        loading_status = ResourceLoader.load_threaded_get_status(
            path,
            progress
        )
        
        if loading_status == ResourceLoader.THREAD_LOAD_LOADED:
            var scene := ResourceLoader.load_threaded_get(path)
            get_tree().change_scene_to_packed(scene)
            break
        
        # Update loading bar
        print("Loading: ", progress[0] * 100, "%")
        await get_tree().process_frame
```

## Loading Screen Pattern

```gdscript
# loading_screen.gd
extends Control

@onready var progress_bar: ProgressBar = $ProgressBar

func load_scene(path: String) -> void:
    show()
    ResourceLoader.load_threaded_request(path)
    
    var progress := []
    var status: int
    
    while true:
        status = ResourceLoader.load_threaded_get_status(path, progress)
        
        if status == ResourceLoader.THREAD_LOAD_LOADED:
            var scene := ResourceLoader.load_threaded_get(path)
            get_tree().change_scene_to_packed(scene)
            break
        elif status == ResourceLoader.THREAD_LOAD_FAILED:
            push_error("Failed to load scene: " + path)
            break
        
        progress_bar.value = progress[0] * 100
        await get_tree().process_frame
    
    hide()
```

## Dynamic Scene Instances

### Add Scene as Child

```gdscript
# Spawn enemy at runtime
const ENEMY_SCENE := preload("res://enemies/goblin.tscn")

func spawn_enemy(position: Vector2) -> void:
    var enemy := ENEMY_SCENE.instantiate()
    enemy.global_position = position
    add_child(enemy)
```

### Instance Management

```gdscript
# Keep track of spawned enemies
var active_enemies: Array[Node] = []

func spawn_enemy(pos: Vector2) -> void:
    var enemy := ENEMY_SCENE.instantiate()
    enemy.global_position = pos
    add_child(enemy)
    active_enemies.append(enemy)
    
    # Clean up when enemy dies
    enemy.tree_exited.connect(
        func(): active_enemies.erase(enemy)
    )

func clear_all_enemies() -> void:
    for enemy in active_enemies:
        enemy.queue_free()
    active_enemies.clear()
```

## Sub-Scenes

```gdscript
# Load UI as sub-scene
@onready var ui := preload("res://ui/game_ui.tscn").instantiate()

func _ready() -> void:
    add_child(ui)
```

## Scene Persistence

```gdscript
# Keep scene loaded when changing scenes
var persistent_scene: Node

func make_persistent(scene: Node) -> void:
    persistent_scene = scene
    scene.get_parent().remove_child(scene)
    get_tree().root.add_child(scene)

func restore_persistent() -> void:
    if persistent_scene:
        get_tree().root.remove_child(persistent_scene)
        add_child(persistent_scene)
```

## Reload Current Scene

```gdscript
# Restart level
get_tree().reload_current_scene()
```

## Scene Caching

```gdscript
# Cache frequently used scenes
var scene_cache: Dictionary = {}

func get_cached_scene(path: String) -> PackedScene:
    if not scene_cache.has(path):
        scene_cache[path] = load(path)
    return scene_cache[path]

# Usage:
var enemy := get_cached_scene("res://enemies/goblin.tscn").instantiate()
```

## Best Practices

### 1. Use SceneTransitioner AutoLoad

```gdscript
# Centralized scene management
# All transitions go through one system
# Consistent fade effects
```

### 2. Preload Common Scenes

```gdscript
# ✅ Good - preload at compile time
const BULLET := preload("res://projectiles/bullet.tscn")

# ❌ Bad - load at runtime
var bullet := load("res://projectiles/bullet.tscn")
```

### 3. Clean Up Before Transition

```gdscript
func change_level() -> void:
    # Clear timers, tweens, etc.
    for timer in get_tree().get_nodes_in_group("timers"):
        timer.stop()
    
    SceneTransitioner.change_scene("res://levels/next.tscn")
```

### 4. Error Handling

```gdscript
func load_scene_safe(path: String) -> bool:
    if not ResourceLoader.exists(path):
        push_error("Scene not found: " + path)
        return false
    
    get_tree().change_scene_to_file(path)
    return true
```

## Reference
- [Godot Docs: SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html)
- [Godot Docs: Background Loading](https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
