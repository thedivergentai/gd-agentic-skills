# skills/autoload-architecture/scripts/autoload_initializer.gd
extends Node

## AutoLoad Initializer Expert Pattern
## Manages explicit initialization order and dependency injection for AutoLoads.

class_name AutoLoadInitializer

var _initialized: Dictionary = {}
var _init_order: Array[StringName] = []

func register_autoload(autoload_name: StringName, init_callback: Callable) -> void:
	_init_order.append(autoload_name)
	_initialized[autoload_name] = {
		"callback": init_callback,
		"complete": false
	}

func initialize_all() -> void:
	print("=== Initializing AutoLoads ===")
	
	for autoload_name in _init_order:
		var data: Dictionary = _initialized[autoload_name]
		if data["complete"]:
			continue
			
		print("Initializing: %s" % autoload_name)
		data["callback"].call()
		data["complete"] = true

func is_initialized(autoload_name: StringName) -> bool:
	return _initialized.get(autoload_name, {}).get("complete", false)

func wait_for_autoload(autoload_name: StringName) -> void:
	while not is_initialized(autoload_name):
		await get_tree().process_frame

## EXPERT USAGE:
## In each AutoLoad's _ready():
##   AutoLoadInitializer.register_autoload(&"GameManager", initialize)
##
## func initialize() -> void:
##   # Heavy initialization here
##   pass
##
## Then in main scene:
##   AutoLoadInitializer.initialize_all()
