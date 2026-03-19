class_name RevivalCheckpointPersistence
extends Resource

## Expert Checkpoint Persistence Resource.
## Stores the last activated checkpoint and associated world state.

@export var last_checkpoint_id: String = ""
@export var checkpoint_pos: Vector3 = Vector3.ZERO
@export var triggered_events: Array[String] = []

func save_state() -> void:
	ResourceSaver.save(self, "user://checkpoint_data.res")

static func load_state() -> RevivalCheckpointPersistence:
	if ResourceLoader.exists("user://checkpoint_data.res"):
		return ResourceLoader.load("user://checkpoint_data.res")
	return RevivalCheckpointPersistence.new()

## Tip: Resource-based saving is faster and more type-safe for checkpoint data than JSON.
