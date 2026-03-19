class_name MetaProgression extends Resource

## Global meta-progression data stored separately from session data.
## Prevents wipe of permanent unlocks upon run permadeath.

@export var global_currency: int = 0
@export var unlocked_ability_ids: Array[StringName] = []
@export var permanent_upgrades: Dictionary = {}

const META_PATH = "user://meta_progression.tres"

func save_global() -> Error:
	return ResourceSaver.save(self, META_PATH)

static func load_global() -> MetaProgression:
	if ResourceLoader.exists(META_PATH):
		return load(META_PATH) as MetaProgression
	return MetaProgression.new()

func increment_currency(amount: int) -> void:
	global_currency += amount
	emit_changed()
