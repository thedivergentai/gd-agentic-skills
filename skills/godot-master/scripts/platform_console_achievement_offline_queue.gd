class_name AchievementOfflineQueue
extends Node

## Expert Achievement/Trophy caching for Offline-ready consoles.
## Queues unlocks locally and flushes to platform services when online.

var _queue_path: String = "user://achievement_queue.dat"
var _pending_ids: Array[StringName] = []

func _ready() -> void:
	_load_queue()

func unlock_achievement(achievement_id: StringName) -> void:
	if _is_online():
		_push_to_platform(achievement_id)
	else:
		_pending_ids.append(achievement_id)
		_save_queue()

func _is_online() -> bool:
	# Check connectivity via platform-specific API
	return true

func _push_to_platform(_id: StringName) -> void:
	# Native SDK call here
	pass

func _save_queue() -> void:
	var f = FileAccess.open(_queue_path, FileAccess.WRITE)
	if f: f.store_var(_pending_ids)

func _load_queue() -> void:
	if FileAccess.file_exists(_queue_path):
		var f = FileAccess.open(_queue_path, FileAccess.READ)
		_pending_ids = f.get_var()
