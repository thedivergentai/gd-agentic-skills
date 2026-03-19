class_name AsyncResourceLoader
extends Node

## Expert boilerplate for background loading with progress indicators.
## Utilizes ResourceLoader.load_threaded_request for non-blocking transitions.

signal loading_completed(resource: Resource)
signal loading_failed(path: String)
signal progress_updated(percent: float)

var _target_path: String = ""

func request_load(path: String) -> void:
	if not ResourceLoader.exists(path):
		loading_failed.emit(path)
		return
		
	_target_path = path
	# Start background thread load
	ResourceLoader.load_threaded_request(path, "", true)
	set_process(true)

func _process(_delta: float) -> void:
	if _target_path == "":
		set_process(false)
		return
		
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(_target_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_updated.emit(progress[0] * 100.0)
		ResourceLoader.THREAD_LOAD_LOADED:
			var res = ResourceLoader.load_threaded_get(_target_path)
			loading_completed.emit(res)
			_target_path = ""
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			loading_failed.emit(_target_path)
			_target_path = ""
