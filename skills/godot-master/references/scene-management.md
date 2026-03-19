---
name: godot-scene-management
description: "Expert blueprint for scene loading, transitions, async (background) loading, instance management, and caching. Covers fade transitions, loading screens, dynamic spawning, and scene persistence. Use when implementing level changes OR dynamic content loading. Keywords scene, loading, transition, async, ResourceLoader, change_scene, preload, PackedScene, fade."
---

# Scene Management

Async loading, transitions, instance pooling, and caching define smooth scene workflows.

## Available Scripts

### [background_resource_loader.gd](../scripts/scene_management_background_resource_loader.gd)
Expert asynchronous scene loading with progress tracking and thread-safe transition.

### [scene_transition_manager.gd](../scripts/scene_management_scene_transition_manager.gd)
Clean implementation of scene fades and transitions using Tweens and Shaders.

### [additive_ui_layering.gd](../scripts/scene_management_additive_ui_layering.gd)
Managing UI overlays and menus without destroying the current world scene.

### [node_unparent_reparent.gd](../scripts/scene_management_node_unparent_reparent.gd)
Safe, transform-preserving reparenting of nodes between different scene trees.

### [persistent_data_preservation.gd](../scripts/scene_management_persistent_data_preservation.gd)
Pattern for using Autoloads to maintain player state and game data across scene changes.

### [scene_instancing_pooling.gd](../scripts/scene_management_scene_instancing_pooling.gd)
High-performance object pooling to eliminate the cost of frequent instantiation and freeing.

### [subviewport_scene_layering.gd](../scripts/scene_management_subviewport_scene_layering.gd)
Running parallel worlds or specialized rendering layers using `SubViewport` nodes.

### [node_path_safe_retrieval.gd](../scripts/scene_management_node_path_safe_retrieval.gd)
Robust node reference architecture using Unique Names and error-guarded @onready.

### [dynamic_script_attachment.gd](../scripts/scene_management_dynamic_script_attachment.gd)
Runtime script manipulation for modding systems or highly dynamic entity behavior.

### [recursive_scene_cleanup.gd](../scripts/scene_management_recursive_scene_cleanup.gd)
Pattern for ensuring zero-leak cleanup and orphan node detection in huge scene graphs.

### [async_scene_manager.gd](../scripts/scene_management_async_scene_manager.gd)
Expert async scene loader with progress tracking, error handling, and transition callbacks.

### [scene_pool.gd](../scripts/scene_management_scene_pool.gd)
Object pooling for frequently spawned scenes (bullets, godot-particles, enemies).

### [scene_state_manager.gd](../scripts/scene_management_scene_state_manager.gd)
Preserves and restores scene state across transitions using "persist" group pattern.

> **MANDATORY - For Smooth Transitions**: Read async_scene_manager.gd before implementing loading screens.


## NEVER Do in Scene Management

- **NEVER load large scenes synchronously** — `load("res://large_scene.tscn")` on the Main Thread causes "hiccups" or full freezes during level transitions. Use `ResourceLoader.load_threaded_request()` for async loading with a progress bar.
- **NEVER use `get_tree().change_scene_to_file()` for transient state** — This method purges the current scene and all its local variables. Use an **Autoload (Singleton)** or a persistent 'Game' node to store state across levels.
- **NEVER instance 100+ identical nodes per frame** — Use **Object Pooling** to reuse bullets, debris, or enemies. Constant `instantiate()` and `queue_free()` calls spike CPU and trigger the Garbage Collector too often.
- **NEVER hardcode `get_node("../../Path/To/Node")`** — These paths break as soon as you move a node in the editor. Use **Scene Unique Names** (`%NodeName`) or `@export var target_node: Node` for robust references.
- **NEVER reparent nodes mid-physics-step without care** — Reparenting can cause one-frame transform "teleports". Always store the `global_transform` and re-apply it after the `add_child()` call.
- **NEVER rely on the SceneTree for 10,000+ objects** — If you don't need SceneTree features (signals, per-node scripts), use `PhysicsServer` and `RenderingServer` directly for raw performance.
- **NEVER forget to handle `NOTIFICATION_WM_CLOSE_REQUEST`** — On desktop, if you don't handle the close request in a persistent node, the game may close during a critical save operation.
- **NEVER use deep recursion for node cleanup** — If a scene has thousands of nodes, `queue_free()` on the root is efficient. Don't try to manually free every child in a loop unless you have specific memory leaks to debug.
- **NEVER mix `SubViewport` and main world inputs without a plan** — By default, input events bubble up. Use `set_input_as_handled()` to prevent UI clicks in a subviewport from triggering gameplay in the main world.
- **NEVER use `change_scene` to "Reset" a level** — It reloads everything from disk. For a quick respawn, just reset the variables and move the player to the start position.

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
- Master Skill: [godot-master](../SKILL.md)
