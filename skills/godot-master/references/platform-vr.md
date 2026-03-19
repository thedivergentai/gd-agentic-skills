---
name: godot-platform-vr
description: "Expert blueprint for VR platforms (Meta Quest, PSVR, SteamVR, Pico) covering XR toolkit (OpenXR), comfort settings (vignetting, snap turning, teleport), motion controls, hand tracking, and 90+ FPS requirements. Use when targeting VR headsets or implementing immersive 3D experiences. Keywords VR, XR, OpenXR, Meta Quest, motion sickness, comfort, locomotion, XRController3D, foveated rendering."
---

# Platform: VR

90+ FPS, comfort-first design, and motion control accuracy define VR development.

## NEVER Do (Expert VR Rules)

### Rendering & Comfort
- **NEVER drop below 90 FPS** — In VR, 72 FPS or less causes instant nausea. You MUST maintain at least 90 FPS (Meta Quest 2/3 typical) and minimize rendering jank.
- **NEVER use smooth rotation without a vignette (comfort mask)** — Smooth rotation causes motion sickness. Always provide snap turning OR dynamic vignetting.
- **NEVER force 3D MSAA if Foveated Rendering is enabled** — Foveation can conflict with MSAA natively in the OpenXR pipeline on some hardware.

### Locomotion & Interaction
- **NEVER skip a teleport locomotion option** — Smooth movement is intolerable for many. Always offer teleportation as an accessibility alternative.
- **NEVER use billboarding for VR UI** — `BILLBOARD_ENABLED` breaks stereoscopic depth cues. Use static `MeshInstance3D` planes with `SubViewports`.
- **NEVER place UI too close or too far** — 0.5m causes eye strain; 10m is unreadable. Optimal distance is 1-3 meters from the player.

### Safety & System
- **NEVER forget to respect physical play area boundaries** — Stepping into real-world objects is a safety risk. Use `XRServer` to fetch guardian bounds.
- **NEVER ignore focus_lost or session_ended signals** — Gracefully handle disconnections or system menu overlays by pausing the simulation.
- **NEVER hardcode XRControllerTracker names** — Use the **OpenXR Action Map** system to decouple gameplay from specific hardware labels.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [vr_openxr_initializer.gd](../scripts/platform_vr_vr_openxr_initializer.gd)
Expert OpenXR initialization with driver support and feature verification.

### [vr_hand_gesture_detector.gd](../scripts/platform_vr_vr_hand_gesture_detector.gd)
Pinch and Grab recognition using `XRHandModifier3D` for hand tracking.

### [vr_locomotion_handler.gd](../scripts/platform_vr_vr_locomotion_handler.gd)
Expert Snap Turn and Comfort Vignette (Shader-less) implementation.

### [vr_passthrough_manager.gd](../scripts/platform_vr_vr_passthrough_manager.gd)
Alpha blending and underlay setup for Mixed Reality (AR/VR) transitions.

### [vr_performance_config.gd](../scripts/platform_vr_vr_performance_config.gd)
Expert Foveated Rendering and Variable Rate Shading (VRS) setup.

### [vr_haptic_sequencer.gd](../scripts/platform_vr_vr_haptic_sequencer.gd)
Complex haptic pulse sequencing using `XRController3D` triggers.

### [vr_physics_hand_controller.gd](../scripts/platform_vr_vr_physics_hand_controller.gd)
Non-clipping, physics-following hands that respect environmental solid.

### [vr_safety_guardian_warner.gd](../scripts/platform_vr_vr_safety_guardian_warner.gd)
Guardian/Chaperone boundary distance warning logic using `XRServer`.

### [vr_headset_focus_guard.gd](../scripts/platform_vr_vr_headset_focus_guard.gd)
Headset-aware pause logic for focus loss (System Menu / Headset Off).

### [vr_input_action_mapper.gd](../scripts/platform_vr_vr_input_action_mapper.gd)
OpenXR Action Map abstraction to decouple logic from hwardware buttons.

---

```gdscript
# Enable XR
func _ready() -> void:
    var xr_interface := XRServer.find_interface("OpenXR")
    if xr_interface and xr_interface.initialize():
        get_viewport().use_xr = true
```

## Comfort Settings

- **Vignetting** during movement
- **Snap turning** (30°/45° increments)
- **Teleport locomotion** option
- **Seated mode** support

## Motion Controls

```gdscript
# XRController3D for hands
@onready var left_hand := $XROrigin3D/LeftController
@onready var right_hand := $XROrigin3D/RightController

func _process(delta: float) -> void:
    if left_hand.is_button_pressed("trigger"):
        grab_with_left()
```

## Performance

- **90 FPS minimum** - Critical for comfort
- **Low latency** - < 20ms motion-to-photon
- **Foveated rendering** if supported

## Best Practices

1. **Comfort First** - Prevent motion sickness
2. **High FPS** - 90+ required
3. **Physical Space** - Respect boundaries
4. **UI Distance** - 1-3m from player

## Reference
- Related: `godot-camera-systems`, `godot-input-handling`


### Related
- Master Skill: [godot-master](../SKILL.md)
