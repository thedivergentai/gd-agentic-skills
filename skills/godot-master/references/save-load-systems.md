---
name: godot-save-load-systems
description: "Expert blueprint for save/load systems using JSON/binary serialization, PERSIST group pattern, versioning, and migration. Covers player progress, settings, game state persistence, and error recovery. Use when implementing save systems OR data persistence. Keywords save, load, JSON, FileAccess, user://, serialization, version migration, PERSIST group."
---

# Save/Load Systems

JSON serialization, version migration, and PERSIST group patterns define robust data persistence.

## NEVER Do

- **NEVER save without a version field** — When you update your game's data structure, old saves will break. Always include a `"version": "1.0.0"` field and implement migration logic.
- **NEVER use absolute OS paths** — Hardcoding `C:/Users/...` will break on every other machine. Always use the `user://` protocol, which Godot maps to the correct OS-specific app data folder.
- **NEVER attempt to save Node references directly** — Nodes are objects, not raw data. Extract the necessary primitive data (positions, health, levels) into a `Dictionary` or `Resource` instead.
- **NEVER forget to close FileAccess handles** — Leaving a file open can lead to handle leaks and save-file corruption. In Godot 4, files auto-close when the variable goes out of scope, but explicit `close()` is safer for long-running logic.
- **NEVER use JSON for very large binary data** — Storing 10MB of texture data as Base64 in JSON is slow and bloats file size. Use binary `store_var()` or separate dedicated asset files.
- **NEVER trust loaded data without validation** — Users can edit save files. Always use `data.get("field", default_value)` and validate that numbers are within expected ranges to prevent crashes.
- **NEVER trigger a save during high-frequency physics or animation updates** — A crash mid-write will corrupt the file. Save only on explicit game events like entering a menu, finishing a level, or at a checkpoint.
- **NEVER modify a save Dictionary while iterating over its keys** — Calling `erase()` or `add()` inside a loop over the same dictionary causes iteration errors. Use `data.duplicate()` to iterate safely.
- **NEVER store raw passwords or sensitive credentials in unencrypted JSON** — If you have sensitive data, use `FileAccess.open_encrypted_with_pass()` to secure it.
- **NEVER use ResourceLoader.load() for massive scenes on the main thread** — It causes a visible freeze. Use `ResourceLoader.load_threaded_request()` to load levels in the background.
- **NEVER rely on get_instance_id() for cross-session identification** — These IDs are assigned at runtime and change every time the game restarts. Generate your own persistent `String` UUIDs for game objects.
- **NEVER forget to call duplicate(true) on a loaded Resource stats block** — If multiple enemies load the same "goblin_stats.tres", they will all share the same health pool unless duplicated.
- **NEVER use the "allow_objects" flag in store_var/get_var for untrusted data** — Setting this to `true` allows full object decoding, which is a major security risk for saves downloaded from the web.
- **NEVER use JSON for data requiring strict type preservation** — JSON converts `Vector3` to a string or dictionary. For strict data types, use `var_to_bytes()` or a binary format.
- **NEVER leave internal metadata (set_meta) in persistent dictionaries** — This unnecessarily inflates save file size. Clean your dictionaries before serialization.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [save_load_patterns.gd](../scripts/save_load_systems_save_load_patterns.gd)
10 Expert patterns: PERSIST group serialization, binary snapshots, JSON safe-parsing, and threaded loading.

### [save_migration_manager.gd](../scripts/save_load_systems_save_migration_manager.gd)
Expert save file versioning with automatic migration between schema versions.

### [save_system_encryption.gd](../scripts/save_load_systems_save_system_encryption.gd)
AES-256 encrypted saves with compression to prevent casual save editing.

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
- Master Skill: [godot-master](../SKILL.md)
