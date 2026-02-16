> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Save/Load Systems**. Accessed via Godot Master.

# Save/Load Systems

Expert blueprint for robust data persistence, including JSON/binary serialization, save file encryption, and version-based migration.

## Available Scripts

### [save_migration_manager.gd](../scripts/save_load_systems_save_migration_manager.gd)
Handles save file versioning and schema updates. Automatically migrates old save files to the current version to prevent data loss after game updates.

### [save_system_encryption.gd](../scripts/save_load_systems_save_system_encryption.gd)
Implements AES-256 encryption and compression for save files. Prevents casual save-editing and protects sensitive player data.


## NEVER Do

- **NEVER save without a version field** — Without a version tag (e.g., `"version": 2`), you cannot safely update your game's data structure without breaking old save files.
- **NEVER use absolute OS paths** — `C:/Users/...` will break on every other machine. Always use the `user://` protocol, which Godot maps to the correct OS-specific app data folder.
- **NEVER attempt to serialize Node references directly** — Nodes are volatile and cannot be saved to disk. Instead, extract their data into a `Dictionary` or `Resource`.
- **NEVER forget to close `FileAccess` handles** — Leaving files open leads to handles leaking and potential data corruption. Use `close()` explicitly or rely on scope-based automatic closure.
- **NEVER save state during active physics or animation frames** — Triggering a save during high-intensity processing increases the risk of a crash mid-write. Only save at designated "Safe" intervals.

---

## The PERSIST Group Pattern
1. Create a group named `"persist"`.
2. Give every persistent node a `save()` method that returns a `Dictionary` of its state.
3. The `SaveManager` iterates through the group, collects the dictionaries, and stores them in a master JSON/binary file.

## Serialization Formats
- **JSON**: Human-readable, easy to debug, but slower and larger. Ideal for settings and simple RPG progress.
- **Binary (`store_var`)**: Smaller and faster, but unreadable by humans. Best for large, complex game states with hundreds of units.

## Data Validation
Always treat loaded data as "untrusted." Use `data.get("key", default_value)` to ensure your game doesn't crash if a user (or a bug) has removed a specific field from the save file.

## Platform-Specific: `user://`
- **Windows**: `%APPDATA%\Godot\app_userdata\[ProjectName]`
- **macOS**: `~/Library/Application Support/Godot/app_userdata/[ProjectName]`
- **Web**: Maps to IndexedDB in the browser's local storage.

## Config Files (`ConfigPacker`)
For game settings (Resolution, Volume), use `ConfigFile`. It provides a standard `.ini` style format that is easier for users to tweak than raw JSON and includes built-in support for sections and types.

## Reference
- [Godot Docs: Saving Games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)
- [Godot Docs: File Paths](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html)
