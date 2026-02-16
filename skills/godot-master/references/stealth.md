> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Stealth**. Accessed via Godot Master.

# Genre: Stealth

Expert blueprint for high-fidelity stealth-action and immersive sim games. Focuses on systemic AI detection (gradual meters), vision/hearing simulation, and alert state management.

## Available Scripts

### [stealth_ai_controller.gd](../scripts/stealth_stealth_ai_controller.gd)
A professional-grade AI controller for stealth NPCs. Features graduated detection (0-100% meters), composite vision shapes (Peripheral vs. Focused), sound propagation along navigation paths, and a robust Alert State machine (Idle -> Suspicious -> Alerted -> Combat).


## NEVER Do

- **NEVER use binary "Seen/Not Seen" detection** — Instantly snapping to an alert state when the player's pixel enters a vision cone feels unfair. Use a **Gradual Detection Meter** that fills based on distance, light level, and player speed.
- **NEVER allow AI to see through solid geometry** — Always perform a `PhysicsRayQueryParameters3D` check between the AI's eye point and the player's sample points. "Wall-hacking" AI destroys the core stealth loop.
- **NEVER use a simple `distance_to()` check for hearing** — Sound shouldn't travel through 3-foot thick stone walls. Calculate sound travel distance along the **Navigation Path** to determine if a guard actually hears a noise.
- **NEVER make combat the optimal path** — If it's easier to shoot everyone than it is to sneak past them, players will stop sneaking. Ensure that "going loud" triggers intense reinforcements or high-risk combat states.
- **NEVER hide the "Why" from the player** — If a player is detected, they should immediately understand why (e.g., "I stepped in a puddle" or "I was standing in the light"). Use visual icons (?, !) and audio barks.
- **NEVER use a single sample point for player visibility** — If only the player's "origin" is sampled, they might be detected while their body is behind cover but their feet are exposed. Sample at least 3 points: Head, Torso, and Feet.

---

## Detection Mechanics: Line of Sight (LOS)
Implement a multi-stage check:
1. **Range Check**: Is the player within the max vision distance?
2. **Angle Check**: Is the player within the FOV cone?
3. **Raycast Check**: Is there a solid wall between the NPC's eyes and the player?
4. **Lighting Check**: Multiply the detection rate by the player's current light level.

## Sound Propagation
When a noise occurs (e.g., a "Rock" distraction or a "Sprint" footstep):
1. Emit a `NoiseEvent` at the target position.
2. Find all NPCs within the `max_audible_range`.
3. Check the **Path Distance** to the coordinate.
4. If `path_distance < sound_volume`, the NPC enters the `SUSPICIOUS` state and investigates the sound's origin.

## Alert States
- **IDLE**: Following a patrol route or standing guard.
- **SUSPICIOUS**: Searching for the source of a noise or a brief glimpse. Yellow "?" icon.
- **ALERTED**: High-alert searching. The NPC knows an intruder is in the area. Orange "!" icon.
- **COMBAT**: Aggressively engaging the player. Red "!!" icon. Triggers a global alarm.

## Lighting and Visibility
Use a `LightDetector` component on the player:
- Sample multiple body points.
- Query the `light_energy` of nearby `OmniLight3D` nodes.
- Check for occluders between the player and the light source.
- Resulting value (0.0 - 1.0) directly feeds into the NPC detection speed.

## Reference
- [Godot Docs: NavigationServer3D](https://docs.godotengine.org/en/stable/classes/class_navigationserver3d.html)
- [GDC: The Stealth of Dishonored](https://www.youtube.com/watch?v=kYv9lS9eU0U)
