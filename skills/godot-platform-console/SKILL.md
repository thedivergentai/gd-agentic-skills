---
name: godot-platform-console
description: "Expert blueprint for console platforms (PlayStation, Xbox, Nintendo Switch) covering controller-first UI, certification requirements (TRCs/TCRs), platform services (achievements, cloud saves), and performance compliance. Use when targeting console releases or implementing gamepad-only interfaces. Keywords console, PlayStation, Xbox, Switch, TRC, TCR, certification, controller, gamepad, achievements."
---

# Platform: Console

Controller-first design, certification compliance, and locked frame rates define console development.

## Available Scripts

### [console_compliance_handler.gd](scripts/console_compliance_handler.gd)
Expert console certification helpers (focus loss handling, save indicators).

## NEVER Do in Console Development

- **NEVER show mouse cursor** — Mouse on console = certification fail. Controllers only. Hide cursor with `Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)`.
- **NEVER skip pause on focus loss** — User presses Home button without pause = TRC violation. Listen to `NOTIFICATION_APPLICATION_FOCUS_OUT`, force pause.
- **NEVER use unlocked frame rate** — Variable FPS = screen tearing + cert fail. Lock to 30 or 60 FPS: `Engine.max_fps = 60` + VSync.
- **NEVER forget D-Pad navigation** — UI only navigable with analog stick? Accessibility fail. MUST support D-Pad for all menus.
- **NEVER hardcode button labels** — "Press A" on PlayStation shows wrong icon. Use `Input.get_joy_button_string()` or platform-specific icon mapping.
- **NEVER exceed platform memory limits** — Switch has ~3.5GB usable RAM. Exceeding = crash/rejection. Profile with Godot Profiler → Memory tab.

---

- **Always show button prompts** (A/B/X/Y or ⬜/✕/△/○)
- **D-Pad navigation** for all menus
- **Back button support** (B/○)
- **No mouse cursor**

## Input Handling

```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton:
        match event.button_index:
            JOY_BUTTON_A:
                on_confirm()
            JOY_BUTTON_B:
                on_cancel()
```

## Performance Requirements

- **Locked 30/60 FPS** - No drops allowed
- **Memory limits** - Strict budgets
- **Certification testing** - QA required

## Platform Services

- Achievements/Trophies
- Cloud saves
- Multiplayer matchmaking
- Platform friends

## Best Practices

1. **Controller-Only** - No mouse/keyboard
2. **Pause on Focus Loss** - Required
3. **Save Prompts** - Must notify saves
4. **Certification** - Follow TRCs/TCRs

## Reference
- Related: `godot-export-builds`, `godot-input-handling`


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
