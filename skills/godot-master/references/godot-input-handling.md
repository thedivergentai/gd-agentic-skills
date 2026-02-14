> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Input Handling**. Accessed via Godot Master.

# Input Handling

Expert blueprint for robust input management, including InputMap actions, input buffering, runtime rebinding, and cross-platform controller support.

## Available Scripts

### [input_buffer.gd](../scripts/godot-input-handling_input_buffer.gd)
Essential for tight platformer and action game-feel. Buffers input actions (like Jump or Dash) for a short duration (e.g., 150ms) so they execute safely even if pressed slightly before the character is grounded or ready.

### [input_remapper.gd](../scripts/godot-input-handling_input_remapper.gd)
Provides logic for runtime input rebinding. Includes conflict detection, support for multiple devices, and persistence of custom controls to `user://` configuration files.


## NEVER Do

- **NEVER poll input in `_process()` for gameplay** — `_process` is frame-rate dependent. Use `_physics_process` for movement or `_unhandled_input` for events to ensure consistency regardless of FPS.
- **NEVER use hardcoded key constants** — `KEY_W` and `KEY_SPACE` prevent players from rebinding controls and can break functionality on non-QWERTY layouts. Always use **InputMap Actions**.
- **NEVER ignore analog deadzones** — Gamepad sticks vary. Without a deadzone (e.g., 0.2), slight stick drift can cause characters to move on their own. Use `Input.get_axis()` with built-in deadzones.
- **NEVER assume a persistent input device** — Players switch between Keyboard and Gamepad dynamically. Monitor `Input.joy_connection_changed` to update on-screen button prompts instantly.
- **NEVER use `_input()` for gameplay actions** — This function triggers for ALL events including GUI clicks. Use `_unhandled_input()` to ensure the event didn't first target a Menu button or UI element.
- **NEVER skip input buffering** — "Eating" a jump input because the player was 1 frame too early is frustrating. A small input buffer is mandatory for professional-feeling character controls.

---

## Action Mapping (InputMap)
Define actions like `jump`, `attack`, and `move_left` in Project Settings.
- Use `Input.is_action_just_pressed("action")` for one-shot triggers.
- Use `Input.is_action_pressed("action")` for continuous held actions.
- Use `Input.get_vector("left", "right", "up", "down")` for normalized movement vectors.

## Input Buffering Flow
1. **Press**: Player presses "Jump".
2. **Buffer**: Store the timestamp of the press.
3. **Check**: In the movement state machine, check if `(current_time - jump_timestamp) < buffer_window`.
4. **Execute**: If valid and grounded, trigger the jump and clear the buffer.

## Runtime Rebinding
1. Erase existing events for an action: `InputMap.action_erase_events("jump")`.
2. Capture new `InputEvent` from user input.
3. Add the event: `InputMap.action_add_event("jump", new_event)`.
4. Save the new map to a `ConfigFile` for next session.

## Multi-Device Support
Determine the last used device (Mouse/Keyboard vs Gamepad) by checking the `InputEvent` type in `_input()`. Update UI icons (e.g., [E] key versus [A] button) accordingly.

## Reference
- [Godot Docs: Input Actions](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)
- [Godot Docs: Controller Support](https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html)
