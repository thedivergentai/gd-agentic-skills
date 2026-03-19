# async_scare_loader.gd
extends Node

# Asynchronous Jump-Scare Loading (Performance Optimization)
# Prevents the game thread from freezing right before a scare by pre-loading resources.
const SCARE_PATH := "res://scares/hallway_ghost.tscn"

func preload_jump_scare() -> void:
    # Requests the resource loader to start loading in the background.
    ResourceLoader.load_threaded_request(SCARE_PATH)

func execute_jump_scare() -> void:
    # Retreives the pre-loaded resource without stalling the main thread.
    var scare_scene := ResourceLoader.load_threaded_get(SCARE_PATH) as PackedScene
    if scare_scene:
        var instance = scare_scene.instantiate()
        get_tree().root.add_child(instance)
