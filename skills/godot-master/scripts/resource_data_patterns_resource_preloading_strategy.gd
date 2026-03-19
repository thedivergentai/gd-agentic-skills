# resource_preloading_strategy.gd
# Preventing frame drops by pre-loading data
extends Node

# EXPERT NOTE: Use a dictionary of preloaded Resources to 
# avoid 'load()' calls during gameplay frame peaks.

var _vfx_cache: Dictionary = {
	"hit": preload("res://vfx/hit.tres"),
	"spark": preload("res://vfx/spark.tres")
}

func get_vfx(key: String) -> Resource:
	return _vfx_cache.get(key)
