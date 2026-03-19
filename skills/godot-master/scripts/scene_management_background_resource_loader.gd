# background_resource_loader.gd
# Async resource loading with progress tracking
extends Node

# EXPERT NOTE: For large levels, use ResourceLoader.load_threaded_request 
# to prevent the game from freezing while loading a new scene.

var _pending_scene: String = ""

func load_scene(path: String):
	_pending_scene = path
	var error = ResourceLoader.load_threaded_request(path)
	if error != OK:
		push_error("Failed to start loading: " + path)

func _process(_delta: float) -> void:
	if _pending_scene == "": return
	
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(_pending_scene, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Update loading bar: progress[0]
			pass
		ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(_pending_scene)
			get_tree().change_scene_to_packed(scene)
			_pending_scene = ""
		ResourceLoader.THREAD_LOAD_FAILED:
			_pending_scene = ""
