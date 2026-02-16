> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Scene Management**. Accessed via Godot Master.

# Scene Management

Async loading, transitions, instance pooling, and caching define smooth scene workflows.

## Available Scripts

### [async_scene_manager.gd](../scripts/scene_management_async_scene_manager.gd)
Expert async scene loader with progress tracking, error handling, and transition callbacks.

### [scene_pool.gd](../scripts/scene_pool.gd)
Object pooling for frequently spawned scenes (bullets, particles, enemies).

### [scene_state_manager.gd](../scripts/scene_management_scene_state_manager.gd)
Preserves and restores scene state across transitions using "persist" group pattern.

> **MANDATORY - For Smooth Transitions**: Read [async_scene_manager.gd](../scripts/scene_management_async_scene_manager.gd) before implementing loading screens.


## NEVER Do in Scene Management

- **NEVER use load() in gameplay code** — `var scene = load("res://level.tscn")` blocks entire game until loaded. Use `preload()` OR `ResourceLoader.load_threaded_request()`.
- **NEVER forget to check THREAD_LOAD_FAILED** — Async loading without status check? Silent failure = black screen. MUST handle `THREAD_LOAD_FAILED` state.
- **NEVER change scenes without cleaning up** — Active timers/tweens persist across scenes = memory leak + unexpected behavior. Stop timers, disconnect signals before transition.
- **NEVER use get_tree().change_scene_to_file() during _ready()** — Changing scene in `_ready()` = crash (scene tree locked). Use `call_deferred("change_scene")`.
- **NEVER instance scenes without null check** — `var obj = scene.instantiate()` if scene load failed? Crash. Check scene != null first.
- **NEVER forget queue_free() on dynamic instances** — Spawned 1000 enemies, all dead, but not freed? Memory leak. Use `queue_free()` OR instance pooling.

---

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
```

## Async (Background) Loading

```gdscript
func load_scene_async(path: String) -> void:
    ResourceLoader.load_threaded_request(path)
    
    var progress := []
    while true:
        var status = ResourceLoader.load_threaded_get_status(path, progress)
        
        if status == ResourceLoader.THREAD_LOAD_LOADED:
            var scene := ResourceLoader.load_threaded_get(path)
            get_tree().change_scene_to_packed(scene)
            break
        
        # Update loading bar
        print("Loading: ", progress[0] * 100, "%")
        await get_tree().process_frame
```

## Dynamic Scene Instances

### Add Scene as Child
```gdscript
const ENEMY_SCENE := preload("res://enemies/goblin.tscn")

func spawn_enemy(position: Vector2) -> void:
    var enemy := ENEMY_SCENE.instantiate()
    enemy.global_position = position
    add_child(enemy)
```

## Scene Persistence
Use a persistent node pattern to move nodes to the `root` before changing scenes, and then re-attach them in the new scene.

## Best Practices
1. **Use SceneTransitioner AutoLoad**: Centralize all scene changes for consistent transitions.
2. **Preload Common Scenes**: Use `preload()` for frequently used assets to avoid runtime hitches.
3. **Clean Up Before Transition**: Stop timers and tweens to prevent memory leaks.
4. **Error Handling**: Always verify resource existence before attempting to change scenes.

## Reference
- [Godot Docs: SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html)
- [Godot Docs: Background Loading](https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html)
