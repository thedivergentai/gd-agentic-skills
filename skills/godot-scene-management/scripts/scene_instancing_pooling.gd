# scene_instancing_pooling.gd
# Object pooling for high-frequency scene instancing
extends Node

@export var scene_to_pool: PackedScene
@export var pool_size := 50

var _pool: Array = []

func _ready() -> void:
	for i in pool_size:
		var instance = scene_to_pool.instantiate()
		instance.visible = false
		instance.set_process(false)
		add_child(instance)
		_pool.append(instance)

func spawn(pos: Vector2):
	for i in _pool:
		if not i.visible:
			i.global_position = pos
			i.visible = true
			i.set_process(true)
			return i
	return null # Pool exhausted
