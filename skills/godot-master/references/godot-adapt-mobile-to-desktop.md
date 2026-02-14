> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Adapt: Mobile to Desktop**. Accessed via Godot Master.

# Adapt: Mobile to Desktop

Expert blueprint for scaling mobile-first projects to PC platforms. Focuses on expanding control schemes (KB/M), increasing graphical fidelity, and adapting UI for larger, higher-resolution displays.

## Available Scripts

### [desktop_input_adapter.gd](../scripts/godot-adapt-mobile-to-desktop_desktop_input_adapter.gd)
Bridges the gap between mobile touch inputs (like virtual joysticks) and standard desktop WASD/Arrow key movement. Provides a unified interface for movement vectors regardless of the active platform.

### [hover_bridge.gd](../scripts/godot-adapt-mobile-to-desktop_hover_bridge.gd)
Re-enables mouse hover interactions that are typically stripped from mobile-only codebases. Automatically adds support for tooltips, mouse-over visual states, and cursor-based interaction logic.


## NEVER Do

- **NEVER ship a PC port with only Virtual Joysticks or touch buttons** — Desktop players expect physical keyboard and mouse support. Leaving touch-only controls on an `exe` build is considered a major quality fail.
- **NEVER lock the game to a single "Mobile-sized" resolution** — PC users have 1080p, 1440p, 4K, and Ultrawide monitors. You MUST implement a resolution settings menu and ensure the UI scales correctly for all aspect ratios.
- **NEVER hide advanced graphical settings** — PC players appreciate the ability to toggle VSync, Anti-Aliasing, and Shadow Quality. Provide a dedicated "Graphics" menu to allow users to tune the game for their hardware.
- **NEVER use the 44pt "Fat Finger" UI scale for mouse input** — UI elements designed for thumbs look oversized and cheap on a PC monitor. Reduce the scale of buttons and icons by 30-50% for the desktop port.
- **NEVER ignore Window Management shortcuts** — Players expect F11 for Fullscreen, Alt+Enter for toggling window modes, and the ability to drag or maximize the game window across multiple monitors.
- **NEVER forget to integrate with Platform APIs** — A desktop port should ideally leverage the host platform's strengths, such as Steam Achievements, Discord Rich Presence, or local filesystem access for modding/config files.

---

## Expanding Control Schemes
- **Movement**: Map WASD and Arrow keys to existing movement vectors.
- **Shortcuts**: Add keyboard hotkeys (e.g., `[I]` for Inventory, `[M]` for Map) to replace manual touch-menu navigation.
- **Precision Aiming**: Use `get_global_mouse_position()` for aiming or directional interactions rather than drag-gestures.

## Graphical Fidelity Upscaling
Desktop hardware is orders of magnitude more powerful than mobile GPUs:
1. **Enable Post-Processing**: SSAO, Glow, SSR, and Volumetric Fog can move from "Disabled" to "Ultra".
2. **Increase Draw Distance**: Push out the `far` plane of cameras and increase shadow atlas resolution to take advantage of more VRAM.
3. **High-DPI Support**: Ensure "Allow Hidpi" is enabled in Project Settings for crisp text on Retina/4K displays.

## UI Layout Expansion
Desktop screens offer more "real estate":
- Move compact, bottom-corner mobile HUD elements to the top corners or edges.
- Enable **Tooltips** that appear on mouse-over to explain complex icons.
- Use **Context Menus** (Right-click) for advanced item management or settings.

## Performance Tuning
Unlock the potential of PC hardware:
- Set `Engine.max_fps = 0` (unlimited) and let VSync or the user's refresh rate handle capping.
- Implement **Resolution Scaling** (FSR/DLSS equivalent scripts) to allow high-fidelity rendering on mid-range GPUs.

## Reference
- [Godot Docs: Multiple Resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)
- [Godot Docs: Input Mapping](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)
