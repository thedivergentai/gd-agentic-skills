---
name: godot-platform-desktop
description: "Expert blueprint for desktop platforms (Windows/Linux/macOS) covering keyboard/mouse controls, settings menus, window management (fullscreen, resolution), keybind remapping, and Steam integration. Use when targeting PC platforms or implementing desktop-specific features. Keywords desktop, Windows, Linux, macOS, settings, keybinds, ConfigFile, DisplayServer, Steam, fullscreen."
---

# Platform: Desktop

Settings flexibility, window management, and kb/mouse precision define desktop gaming.

## NEVER Do (Expert Desktop Rules)

### Window & Display
- **NEVER hardcode resolution or fullscreen modes** — A 1920x1080 fullscreen on a 4K monitor is blurry. Always provide a settings menu with a resolution dropdown and a mode toggle.
- **NEVER ignore DPI scale factors** — Manually centering windows without `DisplayServer.screen_get_scale()` results in incorrect positioning on HiDPI displays.
- **NEVER skip a borderless window option** — Exclusive fullscreen can break multi-monitor focus. Offer `WINDOW_MODE_FULLSCREEN` (borderless).

### Input & Persistence
- **NEVER use `keycode` for movement rebinds** — Use `physical_keycode` to ensure WASD works correctly across international keyboard layouts (AZERTY/Dvorak).
- **NEVER save settings or user data to `res://`** — Filesystem is read-only in exported releases. Always use `user://`.
- **NEVER skip `NOTIFICATION_WM_CLOSE_REQUEST`** — Failing to handle quit signals causes data loss. Intercept and flush and ConfigFile data before `get_tree().quit()`.

### Performance & Integration
- **NEVER run utility tools at max framerate** — Enable `OS.low_processor_usage_mode` to prevent high GPU heat in static desktop apps.
- **NEVER call proprietary SDKs (Steam/Epic) directly** — Always wrap in `Engine.has_singleton()` to prevent crashes in non-store builds.
- **NEVER block the main thread with massive I/O** — Deserializing 100MB+ configs stalls the engine. Offload to `WorkerThreadPool`.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [desktop_window_manager.gd](../scripts/platform_desktop_desktop_window_manager.gd)
Expert DPI-aware multi-monitor window positioning using `DisplayServer`.

### [desktop_settings_persistent.gd](../scripts/platform_desktop_desktop_settings_persistent.gd)
Production settings persistence using `ConfigFile` for persistent INI data.

### [physical_input_rebinder.gd](../scripts/platform_desktop_physical_input_rebinder.gd)
Expert positional rebind system using `physical_keycode` for AZERTY/Dvorak.

### [platform_sdk_wrapper.gd](../scripts/platform_desktop_platform_sdk_wrapper.gd)
Safe PC SDK singleton wrapper (Steamworks/Epic) with crash guards.

### [native_dialog_helper.gd](../scripts/platform_desktop_native_dialog_helper.gd)
Expert native OS file dialogs and system alerts logic.

### [secondary_window_spawner.gd](../scripts/platform_desktop_secondary_window_spawner.gd)
True multi-window management for secondary Viewports/Windows.

### [graceful_shutdown_handler.gd](../scripts/platform_desktop_graceful_shutdown_handler.gd)
Safe close-request interceptor for data flushing and exit guards.

### [low_processor_eco_mode.gd](../scripts/platform_desktop_low_processor_eco_mode.gd)
Eco mode optimization for desktop tools and launchers.

### [desktop_performance_monitor.gd](../scripts/platform_desktop_desktop_performance_monitor.gd)
OS-level hardware detection for dynamic graphics presets.

### [native_shell_executor.gd](../scripts/platform_desktop_native_shell_executor.gd)
Expert native shell command execution and output capture.

---

```gdscript
# settings.gd
extends Control

func _ready() -> void:
    load_settings()
    apply_settings()

func load_settings() -> void:
    var config := ConfigFile.new()
    config.load("user://settings.cfg")
    
    $Graphics/ResolutionDropdown.selected = config.get_value("graphics", "resolution", 0)
    $Graphics/FullscreenCheck.button_pressed = config.get_value("graphics", "fullscreen", false)
    $Audio/MasterSlider.value = config.get_value("audio", "master_volume", 1.0)

func save_settings() -> void:
    var config := ConfigFile.new()
    config.set_value("graphics", "resolution", $Graphics/ResolutionDropdown.selected)
    config.set_value("graphics", "fullscreen", $Graphics/FullscreenCheck.button_pressed)
    config.set_value("audio", "master_volume", $Audio/MasterSlider.value)
    config.save("user://settings.cfg")

func apply_settings() -> void:
    # Resolution
    var resolutions := [Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)]
    var resolution := resolutions[$Graphics/ResolutionDropdown.selected]
    get_window().size = resolution
    
    # Fullscreen
    if $Graphics/FullscreenCheck.button_pressed:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    
    # Audio
    AudioServer.set_bus_volume_db(0, linear_to_db($Audio/MasterSlider.value))
```

## Keyboard Remapping

```gdscript
# Allow players to rebind keys
func rebind_action(action: String, new_key: Key) -> void:
    # Remove existing
    InputMap.action_erase_events(action)
    
    # Add new
    var event := InputEventKey.new()
    event.keycode = new_key
    InputMap.action_add_event(action, event)
    
    # Save
    save_input_map()
```

## Window Management

```gdscript
# Toggle fullscreen
func toggle_fullscreen() -> void:
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
```

## Steam Integration (if using)

```gdscript
# Using GodotSteam plugin
var steam_id: int

func _ready() -> void:
    if Steam.isSteamRunning():
        steam_id = Steam.getSteamID()
        Steam.achievement_progress.connect(_on_achievement_progress)

func unlock_achievement(name: String) -> void:
    Steam.setAchievement(name)
    Steam.storeStats()
```

## Best Practices

1. **Settings** - Extensive graphics/audio options
2. **Keybinds** - Allow remapping
3. **Alt+F4** - Support quit shortcuts
4. **Save Location** - Use `user://` directory

## Reference
- Related: `godot-export-builds`, `godot-save-load-systems`


### Related
- Master Skill: [godot-master](../SKILL.md)
