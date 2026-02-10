---
name: godot-adapt-mobile-to-desktop
description: "Expert patterns for scaling mobile games to desktop including mouse/keyboard controls, increased resolution and graphical fidelity, expanded UI layouts, settings menus, window management, and platform-specific features. Use when creating desktop ports or cross-platform releases. Trigger keywords: mouse_controls, keyboard_shortcuts, resolution_scaling, graphics_settings, fullscreen_toggle, window_modes, Steam_integration, desktop_optimization."
---

# Adapt: Mobile to Desktop

Expert guidance for scaling mobile games to desktop platforms.

## NEVER Do

- **NEVER keep touch-only controls** — Add mouse/keyboard alternatives. Touch controls on desktop feel awkward and limit precision.
- **NEVER lock to mobile resolution** — Desktop can handle 1920x1080+ and higher frame rates. Upscale UI, increase render distance.
- **NEVER hide graphics settings** — Desktop players expect quality options (resolution, VSync, shadows, anti-aliasing).
- **NEVER use mobile-sized UI** — Touch targets (44pt) are too large for mouse. Reduce button/text size by 30-50%.
- **NEVER forget window management** — Players expect fullscreen, borderless, maximize, and multi-monitor support.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [desktop_input_adapter.gd](scripts/desktop_input_adapter.gd)
Bridges virtual joystick logic to keyboard WASD. Maps keys to input vectors and handles high-DPI UI scaling.

### [hover_bridge.gd](scripts/hover_bridge.gd)
Re-enables desktop hover features in mobile-first codebases. Adds tooltips, mouse enter/exit signals, and hover visual feedback.

---

## Control Scheme Expansion

### Touch → Mouse Conversion

```gdscript
# Mobile: Virtual joystick for movement
var direction: Vector2 = virtual_joystick.get_direction()

# ⬇️ Desktop: WASD + mouse aim

extends CharacterBody2D

func _physics_process(delta: float) -> void:
    # Keyboard movement (WASD)
    var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input.normalized() * SPEED
    
    # Mouse aiming
    var mouse_pos := get_global_mouse_position()
    look_at(mouse_pos)
    
    move_and_slide()

# Configure Project Settings → Input Map:
# move_left: A, Left Arrow
# move_right: D, Right Arrow
# move_up: W, Up Arrow
# move_down: S, Down Arrow
```

### Add Keyboard Shortcuts

```gdscript
# desktop_shortcuts.gd
extends Node

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_fullscreen"):
        toggle_fullscreen()
    
    if event.is_action_pressed("quick_save"):
        save_game()
    
    if event.is_action_pressed("toggle_inventory"):
        $UI/Inventory.visible = not $UI/Inventory.visible

func toggle_fullscreen() -> void:
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# Add to Project Settings → Input Map:
# toggle_fullscreen: F11
# quick_save: F5
# toggle_inventory: I, Tab
```

### Scroll Wheel Support

```gdscript
# Mobile: Pinch to zoom
# Desktop: Scroll wheel

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            camera.zoom *= 1.1
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            camera.zoom *= 0.9
```

---

## Graphics Enhancement

### Resolution Scaling

```gdscript
# mobile_settings.gd (mobile)
func _ready() -> void:
    get_viewport().size = Vector2i(1280, 720)  # Mobile resolution

# ⬇️ desktop_settings.gd (desktop)

extends Node

@export var supported_resolutions: Array[Vector2i] = [
    Vector2i(1280, 720),
    Vector2i(1920, 1080),
    Vector2i(2560, 1440),
    Vector2i(3840, 2160)
]

func _ready() -> void:
    if OS.get_name() in ["Windows", "macOS", "Linux"]:
        # Start at native resolution
        var screen_size := DisplayServer.screen_get_size()
        get_window().size = screen_size
        
        # Enable higher  quality
        enable_desktop_graphics()

func enable_desktop_graphics() -> void:
    # Enable MSAA
    get_viewport().msaa_2d = Viewport.MSAA_2X
    get_viewport().msaa_3d = Viewport.MSAA_4X
    
    # Enable screen space AA
    get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
    
    # Higher shadow resolution
    RenderingServer.directional_shadow_atlas_set_size(4096, true)
    
    # Enable post-processing
    var env := get_viewport().world_3d.environment
    if env:
        env.glow_enabled = true
        env.ssao_enabled = true
        env.adjustment_enabled = true
```

### Settings Menu

```gdscript
# graphics_settings.gd
extends Control

@onready var resolution_option: OptionButton = $VBoxContainer/Resolution
@onready var quality_option: OptionButton = $VBoxContainer/Quality
@onready var vsync_check: CheckBox = $VBoxContainer/VSync
@onready var fullscreen_check: CheckBox = $VBoxContainer/Fullscreen

func _ready() -> void:
    populate_settings()
    load_settings()

func populate_settings() -> void:
    # Resolution options
    resolution_option.add_item("1280x720")
    resolution_option.add_item("1920x1080")
    resolution_option.add_item("2560x1440")
    resolution_option.add_item("3840x2160")
    
    # Quality presets
    quality_option.add_item("Low")
    quality_option.add_item("Medium")
    quality_option.add_item("High")
    quality_option.add_item("Ultra")

func _on_resolution_selected(index: int) -> void:
    var resolutions := [
        Vector2i(1280, 720),
        Vector2i(1920, 1080),
        Vector2i(2560, 1440),
        Vector2i(3840, 2160)
    ]
    
    get_window().size = resolutions[index]
    save_settings()

func _on_quality_selected(index: int) -> void:
    match index:
        0:  # Low
            apply_low_quality()
        1:  # Medium
            apply_medium_quality()
        2:  # High
            apply_high_quality()
        3:  # Ultra
            apply_ultra_quality()
    
    save_settings()

func apply_ultra_quality() -> void:
    get_viewport().msaa_3d = Viewport.MSAA_8X
    get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
    RenderingServer.directional_shadow_atlas_set_size(8192, true)
    
    var env := get_viewport().world_3d.environment
    if env:
        env.glow_enabled = true
        env.ssao_enabled = true
        env.ssil_enabled = true
        env.sdfgi_enabled = true

func _on_vsync_toggled(enabled: bool) -> void:
    if enabled:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
    else:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    
    save_settings()

func _on_fullscreen_toggled(enabled: bool) -> void:
    if enabled:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    
    save_settings()

func save_settings() -> void:
    var config := ConfigFile.new()
    config.set_value("graphics", "resolution_index", resolution_option.selected)
    config.set_value("graphics", "quality", quality_option.selected)
    config.set_value("graphics", "vsync", vsync_check.button_pressed)
    config.set_value("graphics", "fullscreen", fullscreen_check.button_pressed)
    config.save("user://settings.cfg")

func load_settings() -> void:
    var config := ConfigFile.new()
    if config.load("user://settings.cfg") == OK:
        resolution_option.selected = config.get_value("graphics", "resolution_index", 1)
        quality_option.selected = config.get_value("graphics", "quality", 2)
        vsync_check.button_pressed = config.get_value("graphics", "vsync", true)
        fullscreen_check.button_pressed = config.get_value("graphics", "fullscreen", false)
        
        # Apply settings
        _on_resolution_selected(resolution_option.selected)
        _on_quality_selected(quality_option.selected)
        _on_vsync_toggled(vsync_check.button_pressed)
        _on_fullscreen_toggled(fullscreen_check.button_pressed)
```

---

## UI Layout Expansion

### Mobile UI → Desktop UI

```gdscript
# Mobile: Compact HUD, large touch buttons
# Scene: MobileHUD.tscn
# - Virtual joystick (bottom-left)
# - Action buttons (bottom-right, 80x80px)

# ⬇️ Desktop: Spread UI, smaller elements

# Scene: DesktopHUD.tscn
# - Health/Mana bars (top-left, 40px tall)
# - Minimap (top-right, 200x200px)
# - Hotbar (bottom-center, 50x50px slots)
# - Chat (bottom-left, resizable)

extends Control

func _ready() -> void:
    if OS.has_feature("mobile"):
        _setup_mobile_ui()
    else:
        _setup_desktop_ui()

func _setup_mobile_ui() -> void:
    # Large buttons, bottom corners
    $VirtualJoystick.visible = true
    $ActionButtons.scale = Vector2(1.5, 1.5)
    $Minimap.visible = false  # Too cluttered

func _setup_desktop_ui() -> void:
    # Compact, corners and edges
    $VirtualJoystick.visible = false
    $ActionButtons.scale = Vector2(0.8, 0.8)
    $Minimap.visible = true
    $ChatBox.visible = true
```

---

## Window Management

### Multi-Monitor Support

```gdscript
# window_manager.gd
extends Node

func _ready() -> void:
    # Detect monitors
    var screen_count := DisplayServer.get_screen_count()
    print("Detected %d monitors" % screen_count)
    
    # Allow window dragging between monitors
    DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

func move_to_monitor(monitor_index: int) -> void:
    var screen_pos := DisplayServer.screen_get_position(monitor_index)
    var screen_size := DisplayServer.screen_get_size(monitor_index)
    
    # Center window on target monitor
    var window_size := get_window().size
    var centered_pos := screen_pos + (screen_size - window_size) / 2
    
    DisplayServer.window_set_position(centered_pos)
```

### Borderless Fullscreen

```gdscript
func set_borderless_fullscreen(enabled: bool) -> void:
    if enabled:
        # Get screen size
        var screen_size := DisplayServer.screen_get_size()
        
        # Set window to screen size
        get_window().size = screen_size
        get_window().position = Vector2i.ZERO
        
        # Remove border
        DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
    else:
        DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
```

---

## Platform-Specific Features

### Steam Integration (Example)

```gdscript
# Requires GodotSteam plugin
extends Node

var steam_initialized := false

func _ready() -> void:
    if OS.get_name() in ["Windows", "Linux", "macOS"]:
        initialize_steam()

func initialize_steam() -> void:
    var init_result := Steam.steamInit()
    if init_result.status == Steam.STEAM_OK:
        steam_initialized = true
        print("Steam initialized")
        
        # Enable achievements
        Steam.requestStats()

func unlock_achievement(achievement_id: String) -> void:
    if steam_initialized:
        Steam.setAchievement(achievement_id)
        Steam.storeStats()
```

### Discord Rich Presence

```gdscript
# Requires Discord SDK integration
extends Node

func update_presence(state: String, details: String) -> void:
    if OS.get_name() == "Windows":
        # Update Discord presence
        # (Requires plugin)
        pass
```

---

## Performance Enhancements

### Unlock Frame Rate

```gdscript
# Mobile: Locked to 60 FPS
Engine.max_fps = 60

# Desktop: Unlock or  match monitor refresh rate
func _ready() -> void:
    if not OS.has_feature("mobile"):
        Engine.max_fps = 0  # Unlimited (use VSync to cap)
        
        # Or match monitor:
        var refresh_rate := DisplayServer.screen_get_refresh_rate()
        Engine.max_fps = int(refresh_rate)
```

### Increased Draw Distance

```gdscript
# Mobile: Low draw distance
var camera: Camera3D
camera.far = 100.0

# Desktop: Higher
camera.far = 500.0

# Also increase shadow distance
var sun: DirectionalLight3D
sun.directional_shadow_max_distance = 200.0  # Up from 50
```

---

## Testing Checklist

- [ ] Mouse controls feel precise (no acceleration issues)
- [ ] All mobile touch controls have keyboard/mouse equivalents
- [ ] Graphics settings menu works correctly
- [ ] Fullscreen, windowed, borderless modes all function
- [ ] Multi-monitor setup works (dragging window, centering)
- [ ] Resolution changes don't crash or distort UI
- [ ] VSync toggle works
- [ ] Runs at 144+ FPS on high-end hardware
- [ ] Settings persist across sessions
- [ ] Game scales well to ultrawide monitors (21:9, 32:9)


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
