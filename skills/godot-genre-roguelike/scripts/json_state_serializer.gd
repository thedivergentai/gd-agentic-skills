class_name StateSerializer extends Node

## JSON-based persistence system for procedurally generated entities.
## Avoids PackedScene bloat for high-variance runtime states.

const SAVE_PATH = "user://run_state.json"

func save_run_state(entities: Array[Node]) -> Error:
	var save_data := []
	for entity in entities:
		if entity.has_method(&"get_save_dict"):
			save_data.append(entity.call(&"get_save_dict"))
            
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
		
	file.store_string(JSON.stringify(save_data))
	return OK

func load_run_state() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		return []
		
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return []
		
	var test_json_conv = JSON.new()
	var error = test_json_conv.parse(file.get_as_text())
	if error == OK:
		return test_json_conv.get_data()
	return []
