---
name: godot-platform-desktop
description: "Expert blueprint for desktop platforms (Windows/Linux/macOS) covering keyboard/mouse controls, settings menus, window management (fullscreen, resolution), keybind remapping, and Steam integration. Use when targeting PC platforms or implementing desktop-specific features. Keywords desktop, Windows, Linux, macOS, settings, keybinds, ConfigFile, DisplayServer, Steam, fullscreen."
---

# Platform: Desktop

Settings flexibility, window management, and kb/mouse precision define desktop gaming.

## Available Scripts

### [desktop_integration_manager.gd](scripts/desktop_integration_manager.gd)
Expert desktop integration (Steam achievements, settings persistence, window management).

## NEVER Do in Desktop Development

- **NEVER hardcode resolution/fullscreen** — 1920x1080 fullscreen on 4K monitor?  Blurry mess. ALWAYS provide settings menu with resolution dropdown + fullscreen toggle.
- **NEVER save settings to `res://`** — `res://` is read-only in exported builds. Use `user://settings.cfg` for persistent config via ConfigFile.
- **NEVER ignore Alt+F4 or Cmd+Q** — Player presses Alt+F4, nothing happens = frustration. Handle `NOTIFICATION_WM_CLOSE_REQUEST` to quit gracefully.
- **NEVER lock rebinding** — Fixed WASD movement ignores AZERTY/Dvorak keyboards. MUST allow InputMap rebinding via settings.
- **NEVER use `linear_to_db()` wrong** — Volume slider 0-1 directly to AudioServer? Perceptually wrong curve. Use `AudioServer.set_bus_volume_db(0, linear_to_db(slider.value))`.
- **NEVER skip borderless fullscreen option** — Exclusive fullscreen breaks Alt+Tab on Windows.  Offer `WINDOW_MODE_EXCLUSIVE_FULLSCREEN` + `WINDOW_MODE_FULLSCREEN` (borderless).

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
- Master Skill: [godot-master](../godot-master/SKILL.md)
