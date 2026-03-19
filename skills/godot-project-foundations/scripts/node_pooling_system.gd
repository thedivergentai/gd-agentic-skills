class_name NodePoolingSystem
extends Node

## Thread-safe, cross-platform Object Pool for high-frequency spawns (bullets, FX).
## Bypasses SceneTree overhead by reusing existing nodes.

@export var pool_size: int = 32
@export var template: PackedScene

var _pool: Array[Node] = []
var _mutex := Mutex.new()

func _ready() -> void:
	for i in range(pool_size):
		_spawn_to_pool()

func _spawn_to_pool() -> void:
	var instance = template.instantiate()
	instance.hide()
	# Set process_mode to disabled while in pool to save cycles
	instance.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(instance)
	_pool.append(instance)

func get_node_from_pool() -> Node:
	_mutex.lock()
	for n in _pool:
		if n.process_mode == Node.PROCESS_MODE_DISABLED:
			n.process_mode = Node.PROCESS_MODE_INHERIT
			n.show()
			_mutex.unlock()
			return n
	
	# Dynamic expansion if pool is empty
	_spawn_to_pool()
	var last = _pool.back()
	last.process_mode = Node.PROCESS_MODE_INHERIT
	last.show()
	_mutex.unlock()
	return last

func return_to_pool(node: Node) -> void:
	_mutex.lock()
	node.hide()
	node.process_mode = Node.PROCESS_MODE_DISABLED
	_mutex.unlock()
