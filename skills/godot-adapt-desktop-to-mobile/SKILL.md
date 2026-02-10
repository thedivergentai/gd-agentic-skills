---
name: godot-adapt-desktop-to-mobile
description: "Expert patterns for porting desktop games to mobile including touch control schemes (virtual joystick, gesture detection), UI scaling for small screens, performance optimization for mobile GPUs, battery life management, and platform-specific features. Use when creating mobile ports or cross-platform mobile builds. Trigger keywords: TouchScreenButton, virtual_joystick, gesture_detector, InputEventScreenTouch, InputEventScreenDrag, mobile_optimization, battery_saving, adaptive_performance, MOBILE_ENABLED."
---

# Adapt: Desktop to Mobile

Expert guidance for porting desktop games to mobile platforms.

## NEVER Do

- **NEVER use mouse position directly** — Touch has no "hover" state. Replace mouse_motion with screen_drag and check InputEventScreenTouch.pressed.
- **NEVER keep small UI elements** — Apple HIG requires 44pt minimum touch targets. Android Material: 48dp. Scale up buttons 2-3x.
- **NEVER forget finger occlusion** — User's finger blocks 50-100px radius. Position critical info ABOVE touch controls, not below.
- **NEVER run at full performance when backgrounded** — Mobile OSs kill apps that drain battery in background. Pause physics, reduce FPS to 1-5 when app loses focus.
- **NEVER use desktop-only features** — Mouse hover, right-click, keyboard shortcuts, scroll wheel don't exist on mobile. Provide touch alternatives.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [mobile_ui_adapter.gd](scripts/mobile_ui_adapter.gd)
Automatic mobile overrides: scales buttons for touch, applies safe area margins, disables heavy effects (SSAO, SDFGI) for battery/performance.

### [virtual_joystick.gd](scripts/virtual_joystick.gd)
Production-ready virtual joystick with multi-touch support, deadzone handling, and visual feedback. Outputs normalized Vector2 direction.

---

## Touch Control Schemes

### Decision Matrix

| Genre | Recommended Control | Example |
|-------|-------------------|---------|
| Platformer | Virtual joystick (left) + jump button (right) | Super Mario Run |
| Top-down shooter | Dual-stick (move left, aim right) | Brawl Stars |
| Turn-based | Direct tap on units/tiles | Into the Breach |
| Puzzle | Tap, swipe, pinch gestures | Candy Crush |
| Card game | Drag-and-drop | Hearthstone |
| Racing | Tilt steering or tap left/right | Asphalt 9 |

### Virtual Joystick

```gdscript
# virtual_joystick.gd
extends Control

signal direction_changed(direction: Vector2)

@export var dead_zone: float = 0.2
@export var max_distance: float = 100.0

var stick_center: Vector2
var is_pressed: bool = false
var touch_index: int = -1

@onready var base: Sprite2D = $Base
@onready var knob: Sprite2D = $Knob

func _ready() -> void:
    stick_center = base.position

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and is_point_inside(event.position):
            is_pressed = true
            touch_index = event.index
        elif not event.pressed and event.index == touch_index:
            is_pressed = false
            reset_knob()
    
    elif event is InputEventScreenDrag and event.index == touch_index:
        update_knob(event.position)

func is_point_inside(point: Vector2) -> bool:
    return base.get_rect().has_point(base.to_local(point))

func update_knob(touch_pos: Vector2) -> void:
    var local_pos := to_local(touch_pos)
    var offset := local_pos - stick_center
    
    # Clamp to max distance
    if offset.length() > max_distance:
        offset = offset.normalized() * max_distance
    
    knob.position = stick_center + offset
    
    # Calculate direction (-1 to 1)
    var direction := offset / max_distance
    if direction.length() < dead_zone:
        direction = Vector2.ZERO
    
    direction_changed.emit(direction)

func reset_knob() -> void:
    knob.position = stick_center
    direction_changed.emit(Vector2.ZERO)
```

### Gesture Detection

```gdscript
# gesture_detector.gd
extends Node

signal swipe_detected(direction: Vector2)  # Normalized
signal pinch_detected(scale: float)  # > 1.0 = zoom in
signal tap_detected(position: Vector2)

const SWIPE_THRESHOLD := 100.0  # Pixels
const TAP_MAX_DISTANCE := 20.0
const TAP_MAX_DURATION := 0.3  # Seconds

var touch_start: Dictionary = {}  # index → {position: Vector2, time: float}
var pinch_start_distance: float = 0.0

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            touch_start[event.index] = {
                "position": event.position,
                "time": Time.get_ticks_msec() * 0.001
            }
        else:
            _handle_release(event)
    
    elif event is InputEventScreenDrag:
        _handle_drag(event)

func _handle_release(event: InputEventScreenTouch) -> void:
    if event.index not in touch_start:
        return
    
    var start_data = touch_start[event.index]
    var distance := event.position.distance_to(start_data.position)
    var duration := (Time.get_ticks_msec() * 0.001) - start_data.time
    
    # Tap detection
    if distance < TAP_MAX_DISTANCE and duration < TAP_MAX_DURATION:
        tap_detected.emit(event.position)
    
    # Swipe detection
    elif distance > SWIPE_THRESHOLD:
        var direction := (event.position - start_data.position).normalized()
        swipe_detected.emit(direction)
    
    touch_start.erase(event.index)

func _handle_drag(event: InputEventScreenDrag) -> void:
    # Pinch detection (requires 2 touches)
    if touch_start.size() == 2:
        var positions := []
        for idx in touch_start.keys():
            if idx == event.index:
                positions.append(event.position)
            else:
                positions.append(touch_start[idx].position)
        
        var current_distance := positions[0].distance_to(positions[1])
        
        if pinch_start_distance == 0.0:
            pinch_start_distance = current_distance
        else:
            var scale := current_distance / pinch_start_distance
            pinch_detected.emit(scale)
            pinch_start_distance = current_distance
```

---

## UI Scaling

### Responsive Layout

```gdscript
# Adjust UI for different screen sizes
extends Control

func _ready() -> void:
    get_viewport().size_changed.connect(_on_viewport_resized)
    _on_viewport_resized()

func _on_viewport_resized() -> void:
    var viewport_size := get_viewport_rect().size
    var aspect_ratio := viewport_size.x / viewport_size.y
    
    # Adjust for different aspect ratios
    if aspect_ratio > 2.0:  # Ultra-wide (tablets in landscape)
        scale_ui_for_tablet()
    elif aspect_ratio < 0.6:  # Tall (phones in portrait)
        scale_ui_for_phone()
    
    # Adjust touch button sizes
    for button in get_tree().get_nodes_in_group("touch_buttons"):
        var min_size := 88  # 44pt * 2 for Retina
        button.custom_minimum_size = Vector2(min_size, min_size)

func scale_ui_for_tablet() -> void:
    # Spread UI to edges, use horizontal space
    $LeftControls.position.x = 100
    $RightControls.position.x = get_viewport_rect().size.x - 100

func scale_ui_for_phone() -> void:
    # Keep  UI at bottom, vertically compact
    $LeftControls.position.y = get_viewport_rect().size.y - 200
    $RightControls.position.y = get_viewport_rect().size.y - 200
```

---

## Performance Optimization

### Mobile-Specific Settings

```gdscript
# project.godot or autoload
extends Node

func _ready() -> void:
    if OS.get_name() in ["Android", "iOS"]:
        apply_mobile_optimizations()

func apply_mobile_optimizations() -> void:
    # Reduce rendering quality
    get_viewport().msaa_2d = Viewport.MSAA_DISABLED
    get_viewport().msaa_3d = Viewport.MSAA_DISABLED
    get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
    
    # Lower shadow quality
    RenderingServer.directional_shadow_atlas_set_size(2048, false)  # Down from 4096
    
    # Reduce particle counts
    for particle in get_tree().get_nodes_in_group("godot-particles"):
        if particle is GPUParticles2D:
            particle.amount = max(10, particle.amount / 2)
    
    # Lower physics tick rate
    Engine.physics_ticks_per_second = 30  # Down from 60
    
    # Disable expensive effects
    var env := get_viewport().world_3d.environment
    if env:
        env.glow_enabled = false
        env.ssao_enabled = false
        env.ssr_enabled = false
```

### Adaptive Performance

```gdscript
# Dynamically adjust quality based on FPS
extends Node

@export var target_fps: int = 60
@export var check_interval: float = 2.0

var timer: float = 0.0
var quality_level: int = 2  # 0=low, 1=med, 2=high

func _process(delta: float) -> void:
    timer += delta
    if timer >= check_interval:
        var current_fps := Engine.get_frames_per_second()
        
        if current_fps < target_fps - 10 and quality_level > 0:
            quality_level -= 1
            apply_quality(quality_level)
        elif current_fps > target_fps + 5 and quality_level < 2:
            quality_level += 1
            apply_quality(quality_level)
        
        timer = 0.0

func apply_quality(level: int) -> void:
    match level:
        0:  # Low
            get_viewport().scaling_3d_scale = 0.5
        1:  # Medium
            get_viewport().scaling_3d_scale = 0.75
        2:  # High
            get_viewport().scaling_3d_scale = 1.0
```

---

## Battery Life Management

### Background Behavior

```gdscript
#  mobile_lifecycle.gd
extends Node

func _ready() -> void:
    get_tree().on_request_permissions_result.connect(_on_permissions_result)

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_APPLICATION_PAUSED:
            _on_app_backgrounded()
        NOTIFICATION_APPLICATION_RESUMED:
            _on_app_foregrounded()

func _on_app_backgrounded() -> void:
    # Reduce FPS drastically
    Engine.max_fps = 5
    
    # Pause physics
    get_tree().paused = true
    
    # Stop audio
    AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

func _on_app_foregrounded() -> void:
    # Restore FPS
    Engine.max_fps = 60
    
    # Resume
    get_tree().paused = false
    AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
```

---

## Platform-Specific Features

### Safe Area Insets (iPhone Notch)

```gdscript
# Handle notch/status bar
func _ready() -> void:
    if OS.get_name() == "iOS":
        var safe_area := DisplayServer.get_display_safe_area()
        var viewport_size := get_viewport_rect().size
        
        # Adjust UI margins
        $TopBar.position.y = safe_area.position.y
        $BottomControls.position.y = viewport_size.y - safe_area.end.y - 100
```

### Vibration Feedback

```gdscript
func trigger_haptic(intensity: float) -> void:
    if OS.has_feature("mobile"):
        # Android
        if OS.get_name() == "Android":
            var duration_ms := int(intensity * 100)
            OS.vibrate_handheld(duration_ms)
        
        # iOS (requires plugin)
        # Use third-party plugin for iOS haptics
```

---

## Input Remapping

### Mouse → Touch Conversion

```gdscript
# Desktop mouse input
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        _on_click(event.position)

# ⬇️ Convert to touch:

func _input(event: InputEvent) -> void:
    # Support both mouse (desktop testing) and touch
    if event is InputEventMouseButton and event.pressed:
        _on_click(event.position)
    elif event is InputEventScreenTouch and event.pressed:
        _on_click(event.position)

func _on_click(position: Vector2) -> void:
    # Handle click/tap
    pass
```

---

## Edge Cases

### Keyboard Popup Blocking UI

```gdscript
# Problem: Virtual keyboard covers text input
# Solution: Detect keyboard, scroll UI up

func _on_text_edit_focus_entered() -> void:
    if OS.has_feature("mobile"):
        # Keyboard height varies; estimate 300px
        var keyboard_offset := 300
        $UI.position.y -= keyboard_offset

func _on_text_edit_focus_exited() -> void:
    $UI.position.y = 0
```

### Accidental Touch Inputs

```gdscript
# Problem: Palm resting on screen triggers inputs
# Solution: Ignore touches near screen edges

func is_valid_touch(position: Vector2) -> bool:
    var viewport_size := get_viewport_rect().size
    var edge_margin := 50.0
    
    return (position.x > edge_margin and
            position.x < viewport_size.x - edge_margin and
            position.y > edge_margin and
            position.y < viewport_size.y - edge_margin)
```

---

## Testing Checklist

- [ ] Touch controls work with fat fingers (test on real device)
- [ ] UI doesn't block gameplay-critical elements
- [ ] Game pauses when app goes to background
- [ ] Performance is 60 FPS on target device (iPhone 12, Galaxy S21)
- [ ] Battery drain is < 10% per hour
- [ ] Safe area respected (notch, status bar)
- [ ] Works in both portrait and landscape
- [ ] Text is readable on smallest target device (iPhone SE)


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
