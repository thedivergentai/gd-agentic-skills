---
name: godot-platform-vr
description: "Expert blueprint for VR platforms (Meta Quest, PSVR, SteamVR, Pico) covering XR toolkit (OpenXR), comfort settings (vignetting, snap turning, teleport), motion controls, hand tracking, and 90+ FPS requirements. Use when targeting VR headsets or implementing immersive 3D experiences. Keywords VR, XR, OpenXR, Meta Quest, motion sickness, comfort, locomotion, XRController3D, foveated rendering."
---

# Platform: VR

90+ FPS, comfort-first design, and motion control accuracy define VR development.

## Available Scripts

### [vr_physics_hand.gd](scripts/vr_physics_hand.gd)
Expert physics-based hand controller with grab detection and velocity throwing.

## NEVER Do in VR Development

- **NEVER drop below 90 FPS** — 72 FPS in VR = instant nausea. MUST maintain 90 FPS minimum (Quest 2/3), 120 FPS preferred. Use Debug → Profiler aggressively.
- **NEVER use smooth rotation without vignetting** — Smooth camera rotation = vestibular mismatch = motion sickness. Provide snap turning (30°/45°) OR vignette during rotation.
- **NEVER place UI too close or too far** — UI at 0.5m = eye strain, at 10m = unreadable. Optimal distance: 1-3m from player.
- **NEVER ignore motion-to-photon latency** — >20ms latency = visible lag in hand tracking = breaks immersion. Minimize physics steps + rendering delay.
- **NEVER skip teleport locomotion option** — Not everyone tolerates smooth locomotion. MUST offer teleport as alternative for accessibility.
- **NEVER forget physical boundaries** — Player punches wall IRL = lawsuit. Use `XRServer.get_reference_frame()` to respect guardian/chaperone bounds.
- **NEVER use standard 3D audio** — Stereo audio in VR = disorienting. Use spatial audio (AudioStreamPlayer3D) for positional sound cues.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)
