> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Platform: Mobile**. Accessed via Godot Master.

# Platform: Mobile

Expert blueprint for Android and iOS platforms. Addresses touch-first interaction, safe area (notch) handling, battery life optimization, and high-performance texture compression.

## Available Scripts

### [mobile_safe_area_handler.gd](../scripts/platform_mobile_mobile_safe_area_handler.gd)
Essential logic for modern mobile screens. Automatically detects and applies safe area insets (to avoid notches and rounded corners) to the root UI container, ensuring critical buttons remain interactive.


## NEVER Do

- **NEVER use standard Mouse events for complex touch logic** — While Godot can emulate mouse from touch, using `InputEventMouseButton` limits you to single-touch and lacks pressure or multi-finger data. Use `InputEventScreenTouch` and `InputEventScreenDrag`.
- **NEVER ignore the Viewport Safe Area** — Designing UI that spans the entire screen will result in content being cut off by the iPhone "dynamic island" or camera punch-holes. Use `DisplayServer.get_display_safe_area()` to margin your UI.
- **NEVER leave the engine running at high FPS in the background** — If the user switches apps, a game running at 60 FPS in the background will drain battery rapidly and may be killed by the OS. Reduce `Engine.max_fps` when the window loses focus.
- **NEVER use Desktop-scale font sizes** — Text that looks fine on a 27" monitor is unreadable on a 6" phone. Use dynamic scaling or specialized mobile UI themes with minimum font sizes of 16-18pt.
- **NEVER skip VRAM compression (ETC2/ASTC)** — Leaving textures uncompressed will cause your app to exceed mobile memory limits and crash. Always enable `rendering/textures/vram_compression/import_etc2_astc` in Project Settings.
- **NEVER block the main thread for save operations** — Writing to the file system on mobile can be slower than on PC. Perform I/O on a background thread to prevent "Application Not Responding" (ANR) flags.

---

## Responsive UI Layouts
Mobile screens vary greatly in aspect ratio (from iPads to ultrawide phones).
- Use **Anchors** and **Containers** (`VBox`, `HBox`) rather than fixed positions.
- Listen for `get_viewport().size_changed` to swap between Landscape and Portrait layouts dynamically.

## Virtual Controls
For action games without physical buttons:
- Implement a **Virtual Joystick** using a `Control` node that tracks relative touch motion.
- Use large, translucent buttons for actions, spaced far enough apart to avoid "fat finger" errors.

## Performance vs. Visuals
Godot 4's "Mobile" renderer is the standard for modern devices. For older hardware, consider the "Compatibility" (OpenGL ES 3.0) renderer.
- Use **Compressed Textures** to save VRAM.
- Reduce draw calls by using **MultiMeshInstance2D/3D** for repetitive environmental objects like grass or particles.

## Battery Life Management
Monitor `NOTIFICATION_APPLICATION_FOCUS_OUT` to:
- Pause the game.
- Lower `Engine.max_fps` to 10 or 20.
- Stop high-frequency network polling.

## Reference
- [Godot Docs: Exporting for Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [Godot Docs: Exporting for iOS](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)
