> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Racing**. Accessed via Godot Master.

# Genre: Racing

Expert blueprint for building arcade and simulation racing games. Focuses on vehicle physics (VehicleBody3D), "Feel" systems for high-speed perception, track validation (Checkpoints), and rubber-banding AI.

## Available Scripts

### [arcade_vehicle_physics.gd](../scripts/racing_arcade_vehicle_physics.gd)
A high-performance vehicle script designed for fun, responsive arcade racing. Includes custom overrides for friction, center of mass (to prevent flipping), and "Drift" logic that rewards cornering with speed boosts.

### [spline_ai_controller.gd](../scripts/racing_spline_ai_controller.gd)
Professional AI for opponent drivers. Navigates a track using a `Path3D` curve, calculates look-ahead vectors for predictive steering, and implements rubber-banding logic to keep races intense.


## NEVER Do

- **NEVER use a rigid camera attachment** — Locking a camera directly to the car's rotation causes intense motion sickness. Use a **Smooth Follow** pattern with `lerp()` and a slight delay to allow the car to tilt and lean within the frame.
- **NEVER skip "Sense of Speed" effects** — Modern racers feel slow without visual trickery. You MUST dynamically increase **FOV** as speed increases, add screen-space **Motion Blur**, and implement **Camera Shake** when hitting high velocities.
- **NEVER prioritize realism over fun** — Real-world car physics often feel sluggish and frustrating in a game. Increase **Gravity Scale** to 2x or 3x and keep wheel friction high until the player explicitly enters a "Drift" state.
- **NEVER ignore racing "Checkpoints"** — Without sequential validation, players will always find shortcuts that bypass 90% of the track. Enforce `Area3D` checkpoints that MUST be passed in order to count a lap.
- **NEVER use static AI speeds** — If the AI is too fast, the player feels hopeless; if too slow, they feel bored. Use **Rubber-Banding**: if the player is far behind, give the AI a slight speed penalty (95%), and if the player is crushing the competition, give the AI a boost (105%).
- **NEVER use `VehicleBody3D` default settings for karts** — Standard suspension is designed for cars. For arcade karts, you often need to rewrite the suspension logic using `RayCast3D` to get that snappy, responsive feel.

---

## High-Speed Perception (Juice)
Implement a `SpeedEffectManager`:
- **FOV**: `camera.fov = base_fov + (current_speed / max_speed) * 15.0`
- **Wind Lines**: Emit particles from the screen edges toward the center.
- **Audio**: Pitch-shift the engine sound up based on the RPM, not just the raw speed.

## Checkpoint and Lap Logic
- **Manager**: An AutoLoad that stores an `Array` of `Area3D` nodes.
- **Validation**: `if current_checkpoint == last_checkpoint + 1`.
- **Reset**: If a player falls off the track, use the `global_transform` of the **Last Valid Checkpoint** to respawn them safely.

## Drifting Mechanic (Arcade)
1. **Trigger**: When the player holds `Shift` while turning.
2. **Physics**: Briefly reduce the `wheel_friction_slip` on the rear wheels.
3. **Visual**: Spawn "Tire Smoke" particles and play a screeching audio loop.
4. **Reward**: Measure the duration of the drift and grant a small "Nitro" boost when the player releases the button.

## AI: Path Following (Path3D)
Opponents should not use standard NavMesh for high-speed racing.
- Use `Path3D` to define the "Racing Line."
- The AI calculates its distance along the path using `curve.get_closest_offset()`.
- Use **Steering Behaviors** (Seek and Flee) to avoid other cars while staying on the line.

## Reference
- [Godot Docs: Simple 3D Car Tutorial](https://docs.godotengine.org/en/stable/tutorials/physics/using_vehicle_body.html)
- [GDC: The Sense of Speed in Racing Games](https://www.youtube.com/watch?v=hcUv1P95n7w)
