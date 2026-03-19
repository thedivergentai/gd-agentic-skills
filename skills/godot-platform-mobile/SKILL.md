---
name: godot-platform-mobile
description: "Expert blueprint for mobile platforms (Android/iOS) covering touch controls, virtual joysticks, responsive UI, safe areas (notches), battery optimization, and app store guidelines. Use when targeting mobile releases or implementing touch input. Keywords mobile, Android, iOS, touch, InputEventScreenTouch, virtual joystick, safe area, battery, app store, orientation."
---

# Platform: Mobile

Touch-first input, safe area handling, and battery optimization define mobile development.

## NEVER Do (Expert Mobile Rules)

### Input & Display
- **NEVER use mouse events for touch interaction** — Relying on `InputEventMouseButton` on mobile is unreliable. Always use `InputEventScreenTouch` and `InputEventScreenDrag` for high-fidelity multi-touch support.
- **NEVER ignore display safe areas (notches/cutouts)** — UI placed behind a camera notch is unusable. Query `DisplayServer.get_display_safe_area()` and offset critical UI accordingly.
- **NEVER assume fixed orientation** — Locking a landscape game without handling the `size_changed` signal leads to broken layouts on foldable devices or tablet orientation shifts.

### Battery & Performance
- **NEVER maintain high framerate when backgrounded** — Keeping an app at 60 FPS in the background drains battery. Use `NOTIFICATION_APPLICATION_PAUSED` to drop `Engine.max_fps` to 1.
- **NEVER use the Forward+ renderer for mobile** — Most mobile GPUs are not optimized for Forward+. Use the dedicated **Mobile** or **Compatibility** renderers for optimal fill-rate.
- **NEVER leave 'ETC2/ASTC' texture compression disabled** — Uncompressed desktop textures will crash mobile devices due to VRAM exhaustion.

### Permissions & OS Integration
- **NEVER assume Android permissions are automatically granted** — You MUST explicitly call `OS.request_permission()` and verify with `OS.get_granted_permissions()`.
- **NEVER call handheld vibration without permission** — On Android, vibration calls are ignored unless the `VIBRATE` permission is enabled in the export preset.
- **NEVER block the main thread for I/O** — Large file saves on mobile can trigger ANR (Application Not Responding) errors. Use background threads.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [mobile_gesture_recognizer.gd](scripts/mobile_gesture_recognizer.gd)
Expert multi-touch logic for pinch-to-zoom and two-finger rotation.

### [adaptive_safe_area_inset.gd](scripts/adaptive_safe_area_inset.gd)
Dynamic safe-area (notch) handling using `DisplayServer` insets.

### [thermal_throttle_monitor.gd](scripts/thermal_throttle_monitor.gd)
Battery and heat management via `NOTIFICATION_APPLICATION_PAUSED`.

### [mobile_iap_flow_boilerplate.gd](scripts/mobile_iap_flow_boilerplate.gd)
Unified boilerplate for Android/iOS In-App Purchases (IAP).

### [haptic_pattern_generator.gd](scripts/haptic_pattern_generator.gd)
Advanced vibration patterns for mobile haptic feedback.

### [android_runtime_permissions.gd](scripts/android_runtime_permissions.gd)
Expert Android permission requesting and verification logic.

### [mobile_sensor_fusion.gd](scripts/mobile_sensor_fusion.gd)
Stable motion controls using Accelerometer and Gravity fusion.

### [orientation_layout_adaptor.gd](scripts/orientation_layout_adaptor.gd)
Adaptive UI swapping for Landscape/Portrait transitions.

### [mobile_vram_optimizer.gd](scripts/mobile_vram_optimizer.gd)
VRAM monitoring and texture compression enforcement rules.

### [native_share_invoker.gd](scripts/native_share_invoker.gd)
OS-level native share sheet integration for social features.

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
