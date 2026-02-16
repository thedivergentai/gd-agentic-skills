# godot-master/scripts/save_load_systems_save_migration_manager.gd
extends Node

## Save System Expert Pattern
## Implements AES256 Encryption and Schema Versioning.

const SAVE_PATH = "user://savegame.dat"
const ENCRYPTION_KEY = "SECRET_XP_KEY_2026" # Should be stored securely
const CURRENT_VERSION = 2

# 1. Encryption Protocols
# Expert logic: Protect player data from trivial hex editing.
func save_game(data: Dictionary) -> void:
    data["_version"] = CURRENT_VERSION
    
    var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, ENCRYPTION_KEY)
    if file:
        file.store_var(data)
        file.close()

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH): return {}
    
    var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, ENCRYPTION_KEY)
    if not file: return {}
    
    var data = file.get_var()
    file.close()
    
    # 2. Data Migration Framework
    # Professional pattern: Handle 'Schema Evolution' automatically.
    var save_version = data.get("_version", 1)
    if save_version < CURRENT_VERSION:
        data = _migrate_data(data, save_version)
        
    return data

func _migrate_data(old_data: Dictionary, from_version: int) -> Dictionary:
    print("Migrating save from v", from_version, " to v", CURRENT_VERSION)
    
    if from_version == 1:
        # Add a new 'mana' field that didn't exist in v1
        old_data["mana"] = 100
        from_version = 2
        
    return old_data

## EXPERT NOTE:
## Use 'ResourceSaver Serialization': To save complex custom 
## Resources (like inventory or full game-states), use 
## 'ResourceSaver.save(my_resource, path)'. This preserves types and 
## nested objects better than JSON.
## NEVER save absolute machine paths in save files; always use 
## 'user://' to ensure cross-platform compatibility (Windows vs Mac).
## For 'Cloud-Proxy Syncing', implement a 'Snapshot' system that 
## creates a temporary unencrypted buffer specifically for Steam 
## Cloud or Epic Online Services APIs.
