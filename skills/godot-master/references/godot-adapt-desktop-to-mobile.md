> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Adapt: Desktop to Mobile**. Accessed via Godot Master.

# Adapt: Desktop to Mobile

Expert blueprint for retrofitting desktop-first projects for mobile hardware. Focuses on touch control schemes, responsive UI reflowing, and aggressive performance/battery optimizations.

## Available Scripts

### [mobile_ui_adapter.gd](../scripts/godot-adapt-desktop-to-mobile_mobile_ui_adapter.gd)
A comprehensive adapter that automatically detects a mobile environment and applies theme-wide overrides. Scales up buttons for touch, applies safe area margins for notches, and disables high-fidelity rendering effects like SSAO for better battery life.

### [virtual_joystick.gd](../scripts/godot-adapt-desktop-to-mobile_virtual_joystick.gd)
A production-ready virtual joystick component. Supports multi-touch, deadzone logic, and visual feedback. Ideal for 2D/3D platformers and action games that rely on normalized movement vectors.


## NEVER Do

- **NEVER assume a "Hover" state exists** — Desktop mouse-over logic does not translate to mobile. You must replace hover interactions with explicit taps or long-press gestures.
- **NEVER keep small UI targets** — Desktop-sized buttons are nearly impossible to hit with a human finger. Godot's UI on mobile must adhere to the 44-48pt minimum touch target size standard.
- **NEVER position critical UI under the player's thumbs** — The lower corners of a mobile device are usually occluded by the user's hands. Keep vital health bars and mini-maps toward the center or top edges of the screen.
- **NEVER allow full-blown desktop post-processing** — Features like SSAO, SSR, and volumetric fog will destroy mobile battery life and cause thermal throttling. Use a dedicated `if OS.has_feature("mobile"):` check to disable them.
- **NEVER ignore the mobile lifecycle** — Failing to pause or lower the frame rate when a user receives a phone call or backgrounds the app can lead to the OS killing your process. Handle `NOTIFICATION_APPLICATION_PAUSED` gracefully.

---

## Input Strategy: From KB/M to Touch
- **Movement**: Replace WASD with a **Virtual Joystick** or **D-Pad**.
- **Actions**: Replace Mouse Clicks with **TouchScreenButton** nodes or custom `InputEventScreenTouch` logic.
- **Gestures**: Implement `InputEventScreenDrag` for swiping through menus or rotating cameras.

## UI Scaling and Safe Areas
Adaptive UI is mandatory for the diverse range of mobile aspect ratios:
- Use **Anchors** to pin UI elements to corners.
- Use **Containers** to handle different screen widths automatically.
- Offset your UI root by `DisplayServer.get_display_safe_area()` to clear camera notches.

## Asset Optimization
To maintain 60 FPS on mobile:
1. Use **ETC2/ASTC** texture compression.
2. Reduce **Physics Tick Rate** (e.g., from 60 to 30) if your game doesn't require high-precision collisions.
3. Lower **Shadow Atlas** resolution for mobile builds.

## Battery Saving Patterns
Implement a "Battery Saver" mode in your settings menu that:
- Caps FPS to 30.
- Lowers the rendering resolution scale.
- Simplifies complex shader logic.

## Reference
- [Godot Docs: Multiple Resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)
- [Godot Docs: Mobile Renderer](https://docs.godotengine.org/en/stable/tutorials/rendering/rendering_methods.html)
