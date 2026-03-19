# student_progress_config.gd
# Saving progress to human-readable ConfigFiles
extends Node

# EXPERT NOTE: ConfigFile is safer than JSON for educational settings 
# as it allows for structured sections and easier recovery.

var config = ConfigFile.new()
const SAVE_PATH = "user://student_profile.cfg"

func save_progress(level_id: String, score: int):
	config.load(SAVE_PATH)
	config.set_value("Progress", level_id, score)
	config.save(SAVE_PATH)

func get_score(level_id: String) -> int:
	config.load(SAVE_PATH)
	return config.get_value("Progress", level_id, 0)
