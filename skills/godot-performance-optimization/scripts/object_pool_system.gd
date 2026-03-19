# object_pool_system.gd
# Minimal allocation strategy for high-frequency objects
extends Node

# EXPERT NOTE: Instantiating nodes is expensive. Pooling 
# avoids the hit by toggling visibility and process mode 
# instead of calling .instantiate() and .queue_free().

@export var pool_size: int = 100
@export var bullet_scene: PackedScene

var pool: Array[Node] = []

func _ready():
	for i in pool_size:
		var node = bullet_scene.instantiate()
		_deactivate_node(node)
		add_child(node)
		pool.append(node)

func spawn():
	for node in pool:
		if not node.visible:
			_activate_node(node)
			return node
	return null

func _activate_node(node):
	node.visible = true
	node.set_process(true)
	node.set_physics_process(true)

func _deactivate_node(node):
	node.visible = false
	node.set_process(false)
	node.set_physics_process(false)
