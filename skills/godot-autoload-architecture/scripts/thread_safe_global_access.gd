# thread_safe_global_access.gd
# Handling global data from background threads
extends Node

# EXPERT NOTE: Modifying Autoload nodes or SceneTree properties 
# from threads is UNSAFE. Use Mutex for data or call_deferred for nodes.

var _shared_data: Dictionary = {}
var _lock: Mutex = Mutex.new()

func update_data_safely(key: String, val: Variant):
	_lock.lock()
	_shared_data[key] = val
	_lock.unlock()

func get_data_safely(key: String) -> Variant:
	_lock.lock()
	var res = _shared_data.get(key)
	_lock.unlock()
	return res
