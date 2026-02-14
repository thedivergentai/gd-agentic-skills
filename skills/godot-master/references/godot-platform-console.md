> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Platform: Console**. Accessed via Godot Master.

# Platform: Console

Expert blueprint for PlayStation, Xbox, and Nintendo Switch platforms. Focuses on controller-first UI, platform certification (TRC/TCR) compliance, and strict performance targets.

## Available Scripts

### [console_compliance_handler.gd](../scripts/godot-platform-console_console_compliance_handler.gd)
Expert component for handling platform-specific certification requirements. Manages focus-loss pausing, user profile switching, save-in-progress indicators, and controller disconnection prompts.


## NEVER Do

- **NEVER show a mouse cursor on console builds** — Seeing a mouse pointer on a console game is an immediate certification failure. Hide the cursor using `Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)`.
- **NEVER skip pausing when the game loses focus** — If a player presses the console's "Home" or "Share" button, the game must pause and mute audio. Listen for `NOTIFICATION_APPLICATION_FOCUS_OUT` to handle this.
- **NEVER use an unlocked frame rate** — Consoles require stable, predictable performance. Use VSync and lock your frame rate to 30 or 60 FPS via `Engine.max_fps` to avoid screen tearing and cert rejection.
- **NEVER ignore D-Pad navigation for menus** — Navigating a menu with only an analog stick is a major accessibility flaw. Ensure every `Control` node is navigable using the D-Pad/Arrows.
- **NEVER hardcode physical button labels** — A "Press B" prompt is correct for Xbox but wrong for Nintendo (where it's technically back) and non-existent on PlayStation. Use dynamic iconography or `Input.get_joy_button_string()`.
- **NEVER exceed the platform's usable memory limit** — Fixed hardware like the Nintendo Switch has limited RAM (approx 3.5GB for games). Monitor your `OS.get_static_memory_usage()` to stay within budget.

---

## Certification Compliance (TRCs/TCRs)
Each platform has a Technical Requirement Checklist. Key items include:
- Support for multiple user profiles.
- Handling controller disconnections with a visible pause menu.
- Displaying a "Save Icon" whenever writing to the memory card/cloud.
- Proper handling of the console's system UI (e.g., keyboard overlays).

## Controller-First UI
- Set **Focus Neighbors** on your buttons so the D-Pad can jump between them logically.
- Highlighting the currently selected button is mandatory.
- Use **Tooltips** or button icons to explain complex actions.

## Performance Profiling
Since consoles are a "known" target:
- Profile your game early on the dev kit.
- Optimization is mandatory. Use the **Mobile** or **Compatibility** renderer if the high-end "Forward+" renderer causes frame drops on lower-spec consoles like the Switch.

## Platform Services
Godot supports console services through specialized (and often private) GDExtensions:
- **Achievements/Trophies**: Syncing local completions with the platform's reward system.
- **Cloud Saves**: Automatic backup of `user://` data.
- **Presence**: Showing what level or mode a player is in on their profile.

## Reference
- [Godot Docs: Godot on Consoles](https://docs.godotengine.org/en/stable/tutorials/platform/consoles.html)
- [W4 Games: Commercial Support for Console Ports](https://w4games.com/)
