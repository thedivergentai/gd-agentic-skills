> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Platform: Desktop**. Accessed via Godot Master.

# Platform: Desktop

Expert blueprint for Windows, Linux, and macOS platforms. Focuses on settings persistence, comprehensive window management, and PC-specific integrations.

## Available Scripts

### [desktop_integration_manager.gd](../scripts/godot-platform-desktop_desktop_integration_manager.gd)
Expert manager for desktop-specific features. Includes Steam API integration (achievements/stats), settings persistence using `ConfigFile`, and advanced window management ($fullscreen/borderless/resolution).


## NEVER Do

- **NEVER hardcode resolution or aspect ratios** — Locking to 1080p on 4K or ultrawide monitors results in blurring or letterboxing. Always provide a resolution dropdown and aspect-ratio-aware UI scaling.
- **NEVER save user settings to `res://`** — This directory is read-only in exported packages. All persistent data (settings, saves) MUST be written to `user://` to ensure write-access across all OS permissions.
- **NEVER ignore OS-level close requests** — If a player presses Alt+F4 or Cmd+Q, the game should respond gracefully. Handle `NOTIFICATION_WM_CLOSE_REQUEST` to prompt for saving or to cleanup resources before quitting.
- **NEVER lock movement to WASD only** — Players on AZERTY or Dvorak layouts need custom keybinds. Always use the **InputMap** system and provide a rebinding interface in your settings menu.
- **NEVER use a linear curve for volume sliders** — Human hearing is logarithmic. Connecting a slider value (0-1) directly to volume will sound wrong. Use `linear_to_db()` for perceived natural volume transitions.
- **NEVER skip Borderless Fullscreen** — Exclusive fullscreen can break Alt+Tabbing on Windows. Provide both "Exclusive Fullscreen" and "Borderless Fullscreen" (Windowed Fullscreen) for the best user experience.

---

## Window Management
Godot 4 uses `DisplayServer` for window control.
- `DisplayServer.window_set_mode(WINDOW_MODE_FULLSCREEN)`
- `DisplayServer.window_set_size(Vector2i(width, height))`
- `DisplayServer.window_set_vsync_mode(VSYNC_ENABLED)`

## Persistent Settings (`ConfigFile`)
Use `ConfigFile` to store settings on the disk:
1. `config.set_value("graphics", "aa_level", 2)`
2. `config.save("user://settings.cfg")`
3. Upon restart, `config.load()` and apply values to the engine.

## Steam Integration
If using **GodotSteam**:
- Ensure `steam_appid.txt` is present in your project root during development.
- Initialize with `Steam.steamInit()`.
- Use `Steam.setAchievement("ACH_WIN_GAME")` and `Steam.storeStats()` to sync with the Steam Cloud.

## File System Access
Use the `DirAccess` and `FileAccess` classes for desktop file operations. For example, creating a "Screenshots" folder in the user's home directory or reading a local metadata file.

## Reference
- [Godot Docs: Desktop Platforms](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_desktop.html)
- [Godot Docs: ConfigFile](https://docs.godotengine.org/en/stable/classes/class_configfile.html)
