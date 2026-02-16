class_name CollectionManager
extends Node

## A manager for tracking collection objectives (e.g., "Find 5/5 Red Eggs").
## Can handle multiple active collections via dictionary tracking.

# Emitted when progress is made: (collection_id, current_count, target_count)
signal collection_updated(id: String, current: int, target: int)

# Emitted when a specific collection is finished
signal collection_completed(id: String)

# Data structure: { "collection_id": { "current": 0, "target": 10 } }
var _active_collections: Dictionary = {}

func start_collection(id: String, target_count: int) -> void:
	_active_collections[id] = {
		"current": 0, 
		"target": target_count
	}
	# Initial update
	collection_updated.emit(id, 0, target_count)

func register_item_collection(id: String) -> void:
	if not _active_collections.has(id):
		# Optional: Auto-start if not explicit? Better to require start() for explicit control.
		# For now, we ignore items that aren't part of an active quest to avoid spam.
		return

	var data = _active_collections[id]
	data["current"] += 1
	
	collection_updated.emit(id, data["current"], data["target"])
	
	if data["current"] >= data["target"]:
		collection_completed.emit(id)
		# Optional: remove from active? Or keep for archival?
		# Keeping it allows UI to query "10/10" states.

func get_progress(id: String) -> Dictionary:
	return _active_collections.get(id, {"current": 0, "target": 0})
