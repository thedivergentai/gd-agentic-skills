---
name: godot-platform-mobile
description: "Expert blueprint for mobile platforms (Android/iOS) covering touch controls, virtual joysticks, responsive UI, safe areas (notches), battery optimization, and app store guidelines. Use when targeting mobile releases or implementing touch input. Keywords mobile, Android, iOS, touch, InputEventScreenTouch, virtual joystick, safe area, battery, app store, orientation."
---

# Platform: Mobile

Touch-first input, safe area handling, and battery optimization define mobile development.

## Available Scripts

### [mobile_safe_area_handler.gd](scripts/mobile_safe_area_handler.gd)
Expert safe area handling for notched screens using anchored margins.

## NEVER Do in Mobile Development

- **NEVER use mouse events for touch** — `InputEventMouseButton` on mobile? Unreliable. Use `InputEventScreenTouch` + `InputEventScreenDrag` for touch.
- **NEVER ignore safe areas** — UI behind iPhone notch = unusable. Call `DisplayServer.get_display_safe_area()`, offset UI by top/bottom insets.
- **NEVER keep 60 FPS when backgrounded** — App in background @ 60 FPS = battery drain + store rejection. Set `Engine.max_fps = 0` on `NOTIFICATION_APPLICATION_FOCUS_OUT`.
- **NEVER use desktop UI sizes** — 12pt font on phone = unreadable. Minimum 16-18pt for mobile. Use `get_viewport().size` to scale dynamically.
- **NEVER forget VRAM compression**  — Uncompressed textures on mobile = out of memory crash. Enable `rendering/textures/vram_compression/import_etc2_astc=true` in project.godot.
- **NEVER block main thread for saves**  — Saving large file on touch = freeze = ANR (Application Not Responding). Use `FileAccess` on worker thread.
- **NEVER ignore orientation changes** — Game locked to portrait but device rotates? Jarring. Handle `size_changed` signal or specify `window/handheld/orientation` in project.godot.

---

```gdscript
# Replace mouse/keyboard with touch
func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            on_touch_start(event.position)
        else:
            on_touch_end(event.position)
    
    elif event is InputEventScreenDrag:
        on_touch_drag(event.position, event.relative)
```

## Virtual Joystick

```gdscript
# virtual_joystick.gd
extends Control

signal joystick_moved(direction: Vector2)

var is_pressed := false
var center: Vector2
var touch_index := -1

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            is_pressed = true
            center = event.position
            touch_index = event.index
        elif event.index == touch_index:
            is_pressed = false
            joystick_moved.emit(Vector2.ZERO)
    
    elif event is InputEventScreenDrag and event.index == touch_index:
        var direction := (event.position - center).normalized()
        joystick_moved.emit(direction)
```

## Responsive UI

```gdscript
# Adapt to screen size
func _ready() -> void:
    get_viewport().size_changed.connect(_on_viewport_resized)
    _on_viewport_resized()

func _on_viewport_resized() -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    var aspect := viewport_size.x / viewport_size.y
    
    if aspect < 1.5:  # Tall screen
        $UI.layout_mode = VBoxContainer.LAYOUT_MODE_VERTICAL
    else:  # Wide screen
        $UI.layout_mode = HBoxContainer.LAYOUT_MODE_HORIZONTAL
```

## Battery Optimization

```gdscript
# Lower frame rate when inactive
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_APPLICATION_FOCUS_OUT:
            Engine.max_fps = 30
        NOTIFICATION_APPLICATION_FOCUS_IN:
            Engine.max_fps = 60
```

## Safe Areas (Notches)

```gdscript
func apply_safe_area() -> void:
    var safe_area := DisplayServer.get_display_safe_area()
    
    # Adjust UI margins
    $UI.offset_top = safe_area.position.y
    $UI.offset_left = safe_area.position.x
```

## Performance Settings

```ini
# project.godot mobile settings
[rendering]
renderer/rendering_method="mobile"
textures/vram_compression/import_etc2_astc=true

[display]
window/handheld/orientation="landscape"
```

## App Store Metadata

- Icons: 512x512 (Android), 1024x1024 (iOS)
- Screenshots: Multiple resolutions
- Privacy policy required
- Age rating

## Best Practices

1. **Touch-First** - Design for fingers, not mouse
2. **Performance** - Target 60 FPS on mid-range
3. **Battery** - Reduce FPS when backgrounded
4. **Permissions** - Request only what you need

## Reference
- Related: `godot-export-builds`, `godot-ui-containers`


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
