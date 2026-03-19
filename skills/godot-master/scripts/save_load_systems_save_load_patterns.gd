# save_load_patterns.gd
extends Node

# 1. Generating Save Data via Groups
# EXPERT NOTE: Gather all nodes tagged "Persist" seamlessly across the Entire SceneTree.
func serialize_world_state() -> Array[Dictionary]:
    var nodes := get_tree().get_nodes_in_group(&"Persist")
    # map returns a new array of dictionaries provided by the node's individual save() methods
    var save_data: Array[Dictionary] = []
    for node in nodes:
        if node.has_method(&"save"):
             save_data.append(node.call(&"save"))
    return save_data

# 2. Writing JSON to user://
# EXPERT NOTE: Safely open the persistent user directory and stringify data for human-readability.
func save_to_json_file(path: String, data: Dictionary) -> void:
    var file := FileAccess.open("user://" + path, FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify(data))

# 3. Reading and Parsing JSON
# EXPERT NOTE: Reads files line-by-line to extract dictionaries safely.
func load_from_json_file(path: String) -> Variant:
    if not FileAccess.file_exists("user://" + path):
        return null
    var file := FileAccess.open("user://" + path, FileAccess.READ)
    var json_string := file.get_as_text()
    return JSON.parse_string(json_string)

# 4. Binary Serialization (Fastest)
# EXPERT NOTE: Use Godot's native Variant serialization for massive performance and complex types.
func save_binary_snapshot(path: String, data: Dictionary) -> void:
    var file := FileAccess.open("user://" + path, FileAccess.WRITE)
    if file:
        # 'false' explicitly disables object decoding (full Objects) for security.
        file.store_var(data, false)

# 5. Saving Config Files (INI format)
# EXPERT NOTE: Create human-readable preference settings for simple key-value pairs.
func update_config_setting(section: String, key: String, value: Variant) -> void:
    var config := ConfigFile.new()
    config.load("user://settings.cfg") # Load existing
    config.set_value(section, key, value)
    config.save("user://settings.cfg")

# 6. Validating File Existence
# EXPERT NOTE: Always check if a save exists before attempting to read it to prevent errors.
func check_save_data_integrity(path: String) -> bool:
    return FileAccess.file_exists("user://" + path)

# 7. Generating Unique IDs
# EXPERT NOTE: Create persistent IDs for nodes so they reconnect cleanly after load.
func get_persist_id(node: Node) -> String:
    # Uses scene unique ID if available, or custom logic
    return str(node.get_instance_id())

# 8. Safely Destroying Old State before Load
# EXPERT NOTE: Delete old persistent objects before loading new ones to prevent duplication.
func wipe_persist_group() -> void:
    var save_nodes := get_tree().get_nodes_in_group(&"Persist")
    for node in save_nodes:
        node.queue_free()

# 9. Saving Resources Directly
# EXPERT NOTE: Serialize full Godot Resource objects directly to disk (.tres or .res).
func save_stat_resource(res: Resource, path: String) -> void:
    ResourceSaver.save(res, "user://" + path)

# 10. Threaded Scene/File Loading
# EXPERT NOTE: Push heavy scene loading or resource parsing to background cores.
func load_level_async(scene_path: String) -> void:
    ResourceLoader.load_threaded_request(scene_path)
