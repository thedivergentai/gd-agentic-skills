---
name: godot-save-load-systems
description: "Expert blueprint for save/load systems using JSON/binary serialization, PERSIST group pattern, versioning, and migration. Covers player progress, settings, game state persistence, and error recovery. Use when implementing save systems OR data persistence. Keywords save, load, JSON, FileAccess, user://, serialization, version migration, PERSIST group."
---

# Save/Load Systems

JSON serialization, version migration, and PERSIST group patterns define robust data persistence.

## Available Scripts

### [save_migration_manager.gd](scripts/save_migration_manager.gd)
Expert save file versioning with automatic migration between schema versions.

### [save_system_encryption.gd](scripts/save_system_encryption.gd)
AES-256 encrypted saves with compression to prevent casual save editing.

> **MANDATORY - For Production**: Read save_migration_manager.gd before shipping to handle schema changes.


## NEVER Do in Save Systems

- **NEVER save without version field** — Game updates, old saves break. MUST include `"version": "1.0.0"` + migration logic for schema changes.
- **NEVER use absolute paths** — `FileAccess.open("C:/Users/...")` breaks on other machines. Use `user://` protocol (maps to OS-specific app data folder).
- **NEVER save Node references** — `save_data["player"] = $Player`? Nodes aren't serializable. Extract data via `player.save_data()` method instead.
- **NEVER forget to close FileAccess** — `var file = FileAccess.open(...)` without `.close()`? File handle leak = save corruption. Use `close()` OR GDScript auto-close on scope exit.
- **NEVER use JSON for large binary data** — 10MB texture as base64 in JSON? Massive file size + slow parse. Use binary format (`store_var`) OR separate asset files.
- **NEVER trust loaded data** — Save file edited by user? `data.get("health", 100)` prevents crash if field missing. VALIDATE all loaded values.
- **NEVER save during physics/animation frames** — `_physics_process` trigger save? File corruption if game crashes mid-write. Save ONLY on explicit events (level complete, menu).

---

### Pattern 1: JSON Save System (Recommended for Most Games)

#### Step 1: Create SaveManager AutoLoad

```gdscript
# save_manager.gd
extends Node

const SAVE_PATH := "user://savegame.save"

## Save data to JSON file
func save_game(data: Dictionary) -> void:
    var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if save_file == null:
        push_error("Failed to open save file: " + str(FileAccess.get_open_error()))
        return
    
    var json_string := JSON.stringify(data, "\t")  # Pretty print
    save_file.store_line(json_string)
    save_file.close()
    print("Game saved successfully")

## Load data from JSON file
func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        push_warning("Save file does not exist")
        return {}
    
    var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if save_file == null:
        push_error("Failed to open save file: " + str(FileAccess.get_open_error()))
        return {}
    
    var json_string := save_file.get_as_text()
    save_file.close()
    
    var json := JSON.new()
    var parse_result := json.parse(json_string)
    if parse_result != OK:
        push_error("JSON Parse Error: " + json.get_error_message())
        return {}
    
    return json.data as Dictionary

## Delete save file
func delete_save() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(SAVE_PATH)
        print("Save file deleted")
```

#### Step 2: Save Player Data

```gdscript
# player.gd
extends CharacterBody2D

var health: int = 100
var score: int = 0
var level: int = 1

func save_data() -> Dictionary:
    return {
        "health": health,
        "score": score,
        "level": level,
        "position": {
            "x": global_position.x,
            "y": global_position.y
        }
    }

func load_data(data: Dictionary) -> void:
    health = data.get("health", 100)
    score = data.get("score", 0)
    level = data.get("level", 1)
    if data.has("position"):
        global_position = Vector2(
            data.position.x,
            data.position.y
        )
```

#### Step 3: Trigger Save/Load

```gdscript
# game_manager.gd
extends Node

func save_game_state() -> void:
    var save_data := {
        "player": $Player.save_data(),
        "timestamp": Time.get_unix_time_from_system(),
        "version": "1.0.0"
    }
    SaveManager.save_game(save_data)

func load_game_state() -> void:
    var data := SaveManager.load_game()
    if data.is_empty():
        print("No save data found, starting new game")
        return
    
    if data.has("player"):
        $Player.load_data(data.player)
```

### Pattern 2: Binary Save System (Advanced, Faster)

For large save files or when human-readability isn't needed:

```gdscript
const SAVE_PATH := "user://savegame.dat"

func save_game_binary(data: Dictionary) -> void:
    var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if save_file == null:
        return
    
    save_file.store_var(data, true)  # true = full objects
    save_file.close()

func load_game_binary() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    
    var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if save_file == null:
        return {}
    
    var data: Dictionary = save_file.get_var(true)
    save_file.close()
    return data
```

### Pattern 3: PERSIST Group Pattern

For auto-saving nodes with the `persist` group:

```gdscript
# Add nodes to "persist" group in editor or via code:
add_to_group("persist")

# Implement save/load in each persistent node:
func save() -> Dictionary:
    return {
        "filename": get_scene_file_path(),
        "parent": get_parent().get_path(),
        "pos_x": position.x,
        "pos_y": position.y,
        # ... other data
    }

func load(data: Dictionary) -> void:
    position = Vector2(data.pos_x, data.pos_y)
    # ... load other data

# SaveManager collects all persist nodes:
func save_all_persist_nodes() -> void:
    var save_nodes := get_tree().get_nodes_in_group("persist")
    var save_dict := {}
    
    for node in save_nodes:
        if not node.has_method("save"):
            continue
        save_dict[node.name] = node.save()
    
    save_game(save_dict)
```

## Best Practices

### 1. Use `user://` Protocol
```gdscript
# ✅ Good - platform-independent
const SAVE_PATH := "user://savegame.save"

# ❌ Bad - hardcoded path
const SAVE_PATH := "C:/Users/Player/savegame.save"
```

**`user://` paths:**
- **Windows**: `%APPDATA%\Godot\app_userdata\[project_name]`
- **macOS**: `~/Library/Application Support/Godot/app_userdata/[project_name]`
- **Linux**: `~/.local/share/godot/app_userdata/[project_name]`

### 2. Version Your Save Format
```gdscript
const SAVE_VERSION := "1.0.0"

func save_game(data: Dictionary) -> void:
    data["version"] = SAVE_VERSION
    # ... save logic

func load_game() -> Dictionary:
    var data := # ... load logic
    if data.get("version") != SAVE_VERSION:
        push_warning("Save version mismatch, migrating...")
        data = migrate_save_data(data)
    return data
```

### 3. Handle Errors Gracefully
```gdscript
func save_game(data: Dictionary) -> bool:
    var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if save_file == null:
        var error := FileAccess.get_open_error()
        push_error("Save failed: " + error_string(error))
        return false
    
    save_file.store_line(JSON.stringify(data))
    save_file.close()
    return true
```

### 4. Auto-Save Pattern
```gdscript
var auto_save_timer: Timer

func _ready() -> void:
    # Auto-save every 5 minutes
    auto_save_timer = Timer.new()
    add_child(auto_save_timer)
    auto_save_timer.wait_time = 300.0
    auto_save_timer.timeout.connect(_on_auto_save)
    auto_save_timer.start()

func _on_auto_save() -> void:
    save_game_state()
    print("Auto-saved")
```

## Testing Save Systems

```gdscript
func _ready() -> void:
    if OS.is_debug_build():
        test_save_load()

func test_save_load() -> void:
    var test_data := {"test_key": "test_value", "number": 42}
    save_game(test_data)
    var loaded := load_game()
    assert(loaded.test_key == "test_value")
    assert(loaded.number == 42)
    print("Save/Load test passed")
```

## Common Gotchas

**Issue**: Saved Vector2/Vector3 not loading correctly
```gdscript
# ✅ Solution: Store as x, y, z components
"position": {"x": pos.x, "y": pos.y}

# Then reconstruct:
position = Vector2(data.position.x, data.position.y)
```

**Issue**: Resource paths not resolving
```gdscript
# ✅ Store resource paths as strings
"texture_path": texture.resource_path

# Then reload:
texture = load(data.texture_path)
```

## Reference
- [Godot Docs: Saving Games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)
- [Godot Docs: File System](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
