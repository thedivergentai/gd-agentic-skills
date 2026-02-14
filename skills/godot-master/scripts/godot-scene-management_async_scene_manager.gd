# skills/scene-management/code/async_scene_manager.gd
extends Node

## Async Scene Manager Expert Pattern
## Implements Threaded Loading with Progress Tracking and Data Payloads.

signal loading_progress(progress: float)
signal loading_complete(scene_resource: PackedScene)

var _target_scene_path: String = ""
var _scene_payload: Dictionary = {}

# 1. Threaded Loading Request
# Expert logic: NEVER use 'change_scene_to_file' for large levels.
func load_scene(path: String, payload: Dictionary = {}) -> void:
    _target_scene_path = path
    _scene_payload = payload
    
    # Start the threaded load
    var err = ResourceLoader.load_threaded_request(path)
    if err != OK:
        push_error("Failed to start loading: ", path)
        return
        
    set_process(true)

func _process(_delta: float) -> void:
    # 2. Async Progress Tracking
    # Professional pattern: Poll status to update UI loading bars.
    var progress = []
    var status = ResourceLoader.load_threaded_get_status(_target_scene_path, progress)
    
    match status:
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            loading_progress.emit(progress[0])
            
        ResourceLoader.THREAD_LOAD_LOADED:
            _finalize_load()
            
        ResourceLoader.THREAD_LOAD_FAILED:
            set_process(false)
            push_error("Threaded load failed for: ", _target_scene_path)

func _finalize_load() -> void:
    set_process(false)
    var new_scene_res = ResourceLoader.load_threaded_get(_target_scene_path)
    var new_scene = new_scene_res.instantiate()
    
    # 3. Scene Payload System (Data Injection)
    # Standardize how to pass complex data before _ready().
    if new_scene.has_method("initialize"):
        new_scene.initialize(_scene_payload)
        
    get_tree().root.add_child(new_scene)
    get_tree().current_scene.queue_free()
    get_tree().current_scene = new_scene
    
    loading_complete.emit(new_scene_res)

## EXPERT NOTE:
## Use 'Memory Profiling': Inside the loading screen, call 
## 'Performance.get_monitor(Performance.MEMORY_STATIC)' and 
## 'print_stray_nodes()' to detect memory leaks during scene swaps.
## For 'scene-management', implement a 'Background Pre-loading' 
## system that starts loading the next level while the player 
## is still finishing the current one, hidden behind a 'Victory' 
## or 'Dialogue' UI to mask the transition entirely.
## NEVER hardcode scene paths; use a 'Registry' resource that 
## maps 'LEVEL_1' to the actual '.tscn' path.
