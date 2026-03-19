# binary_save_manager.gd
extends Node
class_name BinarySaveManager

# Efficient Binary Serialization
# Saves massive world-states (thousands of entity flags) with minimal I/O overhead.

func save_world_state(data: Dictionary, path: String) -> void:
    # Pattern: Use FileAccess.store_var with full_objects=false for clean data.
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file:
        file.store_var(data, false)
        file.close()

func load_world_state(path: String) -> Dictionary:
    if not FileAccess.file_exists(path): return {}
    
    var file := FileAccess.open(path, FileAccess.READ)
    var data = file.get_var(false)
    file.close()
    return data if data is Dictionary else {}
