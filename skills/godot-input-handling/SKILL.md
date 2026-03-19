---
name: godot-input-handling
description: "Expert patterns for input handling covering InputMap actions, InputEvent processing, controller support, rebinding, deadzones, and input buffering. Use when setting up player controls, implementing input systems, or adding gamepad/accessibility features. Keywords InputMap, InputEvent, gamepad, controller, rebinding, deadzone, input buffer."
---

# Input Handling

Handle keyboard, mouse, gamepad, and touch input with proper buffering and accessibility support.

## Available Scripts

### [advanced_input_buffer.gd](scripts/advanced_input_buffer.gd)
Frame-perfect input buffering system for responsive jumps, dashes, and combo chains.

### [safe_runtime_rebind.gd](scripts/safe_runtime_rebind.gd)
Dynamic input rebinding with conflict detection, persistence, and multi-device support.

### [analog_deadzone_manager.gd](scripts/analog_deadzone_manager.gd)
Radial deadzone management for analog sticks to eliminate drift while maintaining natural follow-through.

### [multi_touch_gestures.gd](scripts/multi_touch_gestures.gd)
Handling touch, drags, and pinch-to-zoom gestures for mobile and touchscreen compatibility.

### [input_echo_filter.gd](scripts/input_echo_filter.gd)
Filtering echo events to distinguish between hold-to-navigate (UI) and one-time gameplay actions.

### [mouse_capture_manager.gd](scripts/mouse_capture_manager.gd)
Robust mouse capture and sensitivity scaling logic for FPS and mouse-intensive systems.

### [hold_toggle_accessibility.gd](scripts/hold_toggle_accessibility.gd)
Software-side support for user-defined 'Hold' vs 'Toggle' accessibility preferences.

### [glyph_prompt_manager.gd](scripts/glyph_prompt_manager.gd)
Real-time switching between Keyboard and Gamepad UI prompts based on the last active device.

### [action_state_machine.gd](scripts/action_state_machine.gd)
Tracking the lifecycle of an action ('Just Pressed', 'Held', 'Released') for complex state logic.

### [unhandled_input_priority.gd](scripts/unhandled_input_priority.gd)
Demonstrating the correct use of `_unhandled_input` to prevent gameplay logic from leaking into UI.

> **MANDATORY - For Responsive Controls**: Read input_buffer.gd before implementing jump/dash mechanics.

## NEVER Do in Input Handling

- **NEVER poll input in `_process()` for gameplay actions** — Use `_physics_process()` or `_unhandled_input()`. `_process()` is frame-rate dependent, causing dropped inputs at low FPS [22].
- **NEVER use hardcoded key checks (e.g., `KEY_W`)** — Always use `InputMap` actions. Hardcoded keys prevent rebinding and break compatibility with non-QWERTY layouts [23].
- **NEVER ignore analog stick deadzones** — Drifting sticks at 0.05 magnitude will cause unintended movement. Implement a radial deadzone (not axial) in code or settings [24].
- **NEVER assume a single input device** — Players may switch between Keyboard and Controller mid-session. Use `Input.joy_connection_changed` to update UI prompts dynamically [25].
- **NEVER use `_input()` for gameplay actions** — `_input()` fires for ALL events (including UI). Use `_unhandled_input()` so gameplay logic doesn't trigger while clicking menus [26].
- **NEVER omit input buffering in fast-paced games** — If a player presses jump 50ms before landing, the input is lost without a buffer. Implement a 100-150ms buffer for a "tight" feel [27].
- **NEVER use `Input.is_action_pressed()` for one-time triggers** — It returns true every frame the key is held. Use `_just_pressed` for jumps, attacks, and toggles to avoid logic spam.
- **NEVER implement manual 'Hold vs Toggle' logic in multiple places** — Centralize it in a setting or input wrapper to ensure accessibility consistency across the whole game.
- **NEVER forget to handle `InputEvent.is_echo()` in UI navigation** — Echo events (keyboard repeat) should move menus but rarely should they trigger "Confirm" or "Back" actions.
- **NEVER capture the mouse without a 'Release' shortcut** — If your game crashes or blocks `ui_cancel`, the user is trapped. Always provide a fallback escape for mouse capture.

---

## InputMap Actions

**Setup:** Project Settings → Input Map → Add action

```gdscript
# Check if action pressed this frame
if Input.is_action_just_pressed("jump"):
    jump()

# Check if action held
if Input.is_action_pressed("fire"):
    shoot()

# Check if action released
if Input.is_action_just_released("jump"):
    release_jump()

# Get axis (-1 to 1)
var direction := Input.get_axis("move_left", "move_right")

# Get vector
var input_vector := Input.get_vector("left", "right", "up", "down")
```

## InputEvent Processing

```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.keycode == KEY_ESCAPE and event.pressed:
            pause_game()
    
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            click_position = event.position
```

## Gamepad Support

```gdscript
# Detect controller connection
func _ready() -> void:
    Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(device: int, connected: bool) -> void:
    if connected:
        print("Controller ", device, " connected")
```

## Reference
- [Godot Docs: InputEvent](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
