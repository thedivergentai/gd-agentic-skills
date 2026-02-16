class_name SecretPersistenceHandler
extends Node

## A utility for saving/loading unlocked secrets to user://secrets.cfg.
## This ensures that Easter eggs or unlocked modes persist across game sessions.
## Designed to be an Autoload or a static helper.

const SAVE_PATH = "user://secrets.cfg"
const SECTION_NAME = "UnlockedSecrets"

static func unlock_secret(secret_id: String) -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	# If file doesn't exist, we'll create it. If error is OK or ERR_FILE_NOT_FOUND, proceed.
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_error("Failed to load secrets config: " + str(err))
		return
		
	config.set_value(SECTION_NAME, secret_id, true)
	config.save(SAVE_PATH)

static func is_secret_unlocked(secret_id: String) -> bool:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err != OK:
		return false
		
	return config.get_value(SECTION_NAME, secret_id, false)

static func clear_all_secrets() -> void:
	var config = ConfigFile.new()
	config.save(SAVE_PATH) # Overwrite with empty
