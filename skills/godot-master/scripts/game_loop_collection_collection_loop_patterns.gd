# collection_loop_patterns.gd
extends Node

# 1. Custom MainLoop Extension
# EXPERT NOTE: Extends the absolute lowest level of the engine loop, bypassing the SceneTree entirely.
# Use for high-performance systems or custom engine drivers.
# class_name CustomMainLoop extends MainLoop
# var time_elapsed := 0.0
# func _process(delta: float) -> bool:
#     time_elapsed += delta
#     return Input.is_key_pressed(KEY_ESCAPE) # Returns true to quit the game loop.

# 2. State Machine Pattern Matching
# EXPERT NOTE: Uses Godot 4's advanced match statement for clean state management.
func process_game_state(state: StringName) -> void:
    match state:
        &"playing", &"paused":
            print("Game is active.")
        &"loading":
            print("Transitioning...")
        _:
            push_warning("Unknown state.")

# 3. Proper SceneTree Pausing
# EXPERT NOTE: Halts all nodes that have their process_mode set to inherit/pausable.
func toggle_pause() -> void:
    get_tree().paused = not get_tree().paused

# 4. Awaiting Physics Synchronization
# EXPERT NOTE: Yields execution cleanly until the engine completes the current physics frame.
# Crucial for logic that depends on the latest physics server state.
func sync_with_physics() -> void:
    await get_tree().physics_frame

# 5. Deferred Scene Switching
# EXPERT NOTE: Queues a function to execute safely during the engine's idle time.
func end_level(path: String) -> void:
    call_deferred(&"_deferred_goto_scene", path)
    
func _deferred_goto_scene(path: String) -> void:
    if get_tree().current_scene:
        get_tree().current_scene.free()
    var next_scene = ResourceLoader.load(path) as PackedScene
    var instance = next_scene.instantiate()
    get_tree().root.add_child(instance)
    get_tree().current_scene = instance

# 6. Global Event Broadcasting via Groups
# EXPERT NOTE: Immediately calls a method on all nodes registered to a specific group.
func reset_all_entities() -> void:
    get_tree().call_group(&"entities", &"reset_state")

# 7. Safe Node Casting for State Transitions
# EXPERT NOTE: Uses the 'as' keyword for safe type casting, returning null if the cast fails.
func handle_body_collision(body: Node) -> void:
    var player := body as CharacterBody2D
    if player:
        player.set_physics_process(false) # Example state change

# 8. Asynchronous Threaded Loading
# EXPERT NOTE: Loads heavy game states in the background without freezing the main thread.
func preload_level(path: String) -> void:
    ResourceLoader.load_threaded_request(path)

# 9. Polling Async Load Status
# EXPERT NOTE: Retrieves the background loaded state safely after polling status.
func fetch_loaded_level(path: String) -> PackedScene:
    if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
        return ResourceLoader.load_threaded_get(path) as PackedScene
    return null

# 10. Frame Throttling / Modulo Processing
# EXPERT NOTE: Throttles heavy loop calculations by only executing every Nth frame.
func _process(_delta: float) -> void:
    if Engine.get_process_frames() % 5 == 0:
        # Run expensive logic (e.g., distant AI, non-critical UI updates)
        pass
