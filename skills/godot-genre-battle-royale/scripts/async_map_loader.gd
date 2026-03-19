# async_map_loader.gd
# Non-blocking map chunk streaming
extends Node

# EXPERT NOTE: BR maps are huge. Load sectors in background threads 
# to prevent frame drops during exploration.

func load_sector(path: String):
	ResourceLoader.load_threaded_request(path)

func _process(_delta):
	var progress = []
	var status = ResourceLoader.load_threaded_get_status("res://levels/sector_a.tscn", progress)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get("res://levels/sector_a.tscn")
		_attach_sector(scene)

func _attach_sector(_s): pass
