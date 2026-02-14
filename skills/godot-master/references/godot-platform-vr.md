> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Platform: VR**. Accessed via Godot Master.

# Platform: VR

Expert blueprint for Virtual Reality platforms (Meta Quest, PSVR2, SteamVR) using OpenXR. Focuses on comfort-first locomotion, physics-based interaction, and high-performance stereo rendering.

## Available Scripts

### [vr_physics_hand.gd](../scripts/godot-platform-vr_vr_physics_hand.gd)
Expert logic for physics-based hand interactions. Handles smooth object-grabbing, velocity-inherited throwing, and haptic feedback triggers for immersive VR input.


## NEVER Do

- **NEVER allow the frame rate to drop below 72/90 FPS** — Frame drops in VR lead to immediate vestibular mismatch and motion sickness. Maintain a strict 90 FPS budget; use the Godot Profiler to identify and eliminate spikes.
- **NEVER use smooth camera rotation without comfort aids** — Instant smooth turning causes nausea for most users. Always provide **Snap Turning** (set increments of 30°/45°) as the default, or use a vignette effect to reduce peripheral vision during movement.
- **NEVER place UI or text in the user's "Near Clip" zone** — UI closer than 0.5 meters will cause significant eye strain (vergence-accommodation conflict). Optimal UI placement is 1.5 to 3.0 meters away in world-space.
- **NEVER skip Teleport locomotion** — While "Smooth Walk" is immersive, many users cannot play without Teleportation. Always include it as a comfort option for accessibility.
- **NEVER ignore the Hardware Guardian/Boundary** — Do not place interactive objects outside the player's calibrated physical space. Respect the `XRServer.get_reference_frame()` to keep users safe.
- **NEVER use screen-space effects for VR** — Bloom, lens flares, and screen-space reflections (SSR) don't work correctly in stereo-vision and can look "flat" or distorted. Use world-space solutions or shaders optimized for VR.

---

## XR Setup (OpenXR)
1. Enable OpenXR in Project Settings.
2. Initialize the interface:
```gdscript
var interface = XRServer.find_interface("OpenXR")
if interface and interface.initialize():
    get_viewport().use_xr = true
```
3. Use the `XROrigin3D` node as the player's root and `XRCamera3D` for the head.

## Comfort Locomotion Patterns
- **Snap Turn**: Rotates the `XROrigin3D` instantly by a set degree.
- **Teleport**: Raycast from the controller to a walkable surface; move the `XROrigin3D` root on release.
- **Tunneling (Vignette)**: Darkens the edges of the screen during locomotion to reduce perceived motion.

## Physical Interaction
Instead of parenting a grabbed object to the hand (visual tracking), use **Physics Constraints** (Joints) or drive the hand's `CharacterBody3D` toward the controller's transform. This allows objects to collide realistically with the environment while held.

## Stereo Rendering Performance
- Use the **Mobile** renderer for standalone headsets (Quest/Pico).
- Enable **Vulkan Foveated Rendering** if the hardware supports it (reduces resolution at screen edges to save GPU cycles).
- Prefer **MultiMeshInstance3D** for large numbers of similar objects (e.g., foliage) to reduce draw calls.

## Reference
- [Godot Docs: Virtual Reality (VR)](https://docs.godotengine.org/en/stable/tutorials/xr/introducing_xr.html)
- [Godot VR Toolkit (GitHub)](https://github.com/GodotVR/godot-xr-tools)
