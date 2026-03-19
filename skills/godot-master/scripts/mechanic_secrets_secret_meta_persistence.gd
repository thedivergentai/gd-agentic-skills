class_name SecretMetaPersistence
extends Node

## Expert Meta-Save Handler.
## Manages global unlocks (e.g., sound test, secret characters) across all save slots.

const META_PATH = "user://meta_secrets.cfg"
var meta_config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	if FileAccess.file_exists(META_PATH):
		meta_config.load(META_PATH)

func unlock_meta_secret(secret_id: String) -> void:
	meta_config.set_value("Ulocks", secret_id, true)
	meta_config.save(META_PATH)

func is_unlocked(secret_id: String) -> bool:
	return meta_config.get_value("Ulocks", secret_id, false)

## Rule: Separate Meta-Unlocks from Game-Saves so players don't lose 'Gallery' items when starting a New Game.
