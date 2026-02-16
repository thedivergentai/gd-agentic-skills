# godot-master/scripts/resource_data_patterns_resource_pool.gd
extends RefCounted

## Resource Pool Expert Pattern
## Object pooling for Resource instances to reduce allocation overhead.

class_name ResourcePool

var _pool: Array = []
var _resource_script: GDScript
var _max_size: int

func _init(resource_type: GDScript, pool_size: int = 10) -> void:
	_resource_script = resource_type
	_max_size = pool_size
	_prewarm(pool_size)

func _prewarm(count: int) -> void:
	for i in range(count):
		_pool.append(_create_instance())

func _create_instance() -> Resource:
	if _resource_script:
		return _resource_script.new()
	return null

func acquire() -> Resource:
	if _pool.is_empty():
		return _create_instance()
	return _pool.pop_back()

func release(resource: Resource) -> void:
	if _pool.size() < _max_size:
		_pool.append(resource)

func clear() -> void:
	_pool.clear()

## EXPERT USAGE:
## const DamageInfo := preload("res://data/damage_info.gd")
## var damage_pool := ResourcePool.new(DamageInfo, 50)
##
## func apply_damage():
##   var damage := damage_pool.acquire()
##   damage.amount = 10
##   # use damage...
##   damage_pool.release(damage)
