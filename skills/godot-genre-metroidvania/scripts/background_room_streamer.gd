# background_room_streamer.gd
extends Node
class_name BackgroundRoomStreamer

# Background Room Streaming
# Prevents lag spikes during room transitions by threading the load.

func preload_room(path: String) -> void:
    # Requests the room scene to be loaded on a background thread.
    ResourceLoader.load_threaded_request(path)

func fetch_loaded_room(path: String) -> PackedScene:
    # Retrieves the loaded scene safely without stalling the main thread.
    # Returns null if not ready yet.
    if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
        return ResourceLoader.load_threaded_get(path) as PackedScene
    return null
