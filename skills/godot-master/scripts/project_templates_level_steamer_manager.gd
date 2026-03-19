class_name LevelStreamerManager
extends Node

## Expert Dynamic Background Level-Loading.
## Streams scenes across background CPU cores using ResourceLoader.load_threaded_request.

var _loading_path: String = ""

func load_level_async(path: String) -> void:
	_loading_path = path
	var err = ResourceLoader.load_threaded_request(path, "", true)
	if err != OK:
		push_error("Streamer: Failed to request " + path)

func _process(_delta: float) -> void:
	if _loading_path.is_empty(): return
	
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(_loading_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			var packed = ResourceLoader.load_threaded_get(_loading_path) as PackedScene
			# Standard transition in professional templates: use change_scene_to_packed
			get_tree().change_scene_to_packed(packed)
			_loading_path = ""
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Streamer: Failed to load " + _loading_path)
			_loading_path = ""
