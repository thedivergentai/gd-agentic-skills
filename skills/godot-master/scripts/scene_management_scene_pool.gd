# godot-master/scripts/scene_management_scene_pool.gd
extends Node

## Scene Pool Expert Pattern
## Object pooling for frequently spawned/destroyed scenes to reduce instantiation overhead.

class_name ScenePool

var _pool: Dictionary = {}  # PackedScene path → Array of inactive instances

func prewarm(scene_path: String, count: int) -> void:
	var scene := load(scene_path) as PackedScene
	if not scene:
		push_error("Failed to load scene: %s" % scene_path)
		return
		
	if scene_path not in _pool:
		_pool[scene_path] = []
		
	for i in range(count):
		var instance := scene.instantiate()
		instance.set_meta("_pooled", true)
		_pool[scene_path].append(instance)

func acquire(scene_path: String, parent: Node) -> Node:
	if scene_path not in _pool or _pool[scene_path].is_empty():
		# Pool empty, create new instance
		var scene := load(scene_path) as PackedScene
		var instance := scene.instantiate()
		instance.set_meta("_pooled", true)
		parent.add_child(instance)
		return instance
	
	# Reuse pooled instance
	var instance := _pool[scene_path].pop_back()
	parent.add_child(instance)
	return instance

func release(instance: Node) -> void:
	if not instance.has_meta("_pooled"):
		instance.queue_free()
		return
		
	var scene_path := instance.scene_file_path
	if scene_path.is_empty():
		instance.queue_free()
		return
		
	instance.get_parent().remove_child(instance)
	
	if scene_path not in _pool:
		_pool[scene_path] = []
	_pool[scene_path].append(instance)

func clear_pool(scene_path: String = "") -> void:
	if scene_path.is_empty():
		for path in _pool:
			for instance in _pool[path]:
				instance.queue_free()
		_pool.clear()
	elif scene_path in _pool:
		for instance in _pool[scene_path]:
			instance.queue_free()
		_pool.erase(scene_path)

## EXPERT USAGE:
## var pool := ScenePool.new()
## pool.prewarm("res://projectiles/bullet.tscn", 50)
##
## # Spawn
## var bullet := pool.acquire("res://projectiles/bullet.tscn", self)
##
## # Return to pool
## pool.release(bullet)
