# async_chunk_loader.gd
extends Node
class_name AsyncChunkLoader

# Background Async Chunk Streamer
# Loads massive open-world chunks dynamically without stalling the main thread.

var _loading_tasks: Dictionary = {}

func request_chunk_load(chunk_id: String, path: String) -> void:
    # Pattern: Use ResourceLoader.load_threaded_request for non-blocking I/O.
    var error := ResourceLoader.load_threaded_request(path)
    if error == OK:
        _loading_tasks[chunk_id] = path

func _process(_delta: float) -> void:
    for chunk_id in _loading_tasks.keys():
        var path: String = _loading_tasks[chunk_id]
        var status := ResourceLoader.load_threaded_get_status(path)
        
        if status == ResourceLoader.THREAD_LOAD_LOADED:
            var chunk_scene := ResourceLoader.load_threaded_get(path) as PackedScene
            # EXTREMELY IMPORTANT: Defer instantiation to the main thread.
            call_deferred("_finalize_chunk_instance", chunk_id, chunk_scene)
            _loading_tasks.erase(chunk_id)

func _finalize_chunk_instance(_chunk_id: String, scene: PackedScene) -> void:
    if scene:
        var instance := scene.instantiate()
        add_child(instance)
