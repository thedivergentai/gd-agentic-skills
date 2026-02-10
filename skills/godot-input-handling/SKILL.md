---
name: godot-input-handling
description: "Expert patterns for input handling covering InputMap actions, InputEvent processing, controller support, rebinding, deadzones, and input buffering. Use when setting up player controls, implementing input systems, or adding gamepad/accessibility features. Keywords InputMap, InputEvent, gamepad, controller, rebinding, deadzone, input buffer."
---

# Input Handling

Handle keyboard, mouse, gamepad, and touch input with proper buffering and accessibility support.

## Available Scripts

### [input_buffer.gd](scripts/input_buffer.gd)
Input buffering for responsive controls - buffers actions for 150ms to ensure tight game feel.

### [input_remapper](scripts/input_remapper.gd)
Runtime input rebinding with conflict detection and save/load persistence.

> **MANDATORY - For Responsive Controls**: Read input_buffer.gd before implementing jump/dash mechanics.

## NEVER Do in Input Handling

- **NEVER poll input in `_process()` for gameplay actions** — Use `_physics_process()` or `_unhandled_input()`_process()` = frame-rate dependent, causes input drops at low FPS.
- **NEVER use hardcoded key checks (`KEY_W`, `KEY_SPACE`)** — Use InputMap actions. Hardcoded keys = no rebinding, breaks non-QWERTY keyboards.
- **NEVER ignore controller deadzones** — Stick drift at 0.05 magnitude = character walks alone. ALWAYS implement `Input.get_axis()` with 0.15-0.2 deadzone.
- **NEVER assume single input device** — Player might switch keyboard → gamepad mid-session. Listen to `Input.joy_connection_changed` and update UI prompts dynamically.
- **NEVER use `//_input()` for gameplay actions** — `_input()` fires for ALL events (including UI). Use `_unhandled_input()` which only fires if UI didn't consume the event.
- **NEVER forget input buffering for responsive controls** — Player presses jump 50ms before landing? Without buffer, jump is lost. Buffer inputs for 100-150ms for tight game-feel.

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
