> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Horror**. Accessed via Godot Master.

# Genre: Horror

Expert blueprint for psychological and survival horror games. Focuses on psychological tension systems (The "Director"), sensory-based AI, atmospheric lighting, and resource scarcity.

## Available Scripts

### [predator_stalking_ai.gd](../scripts/godot-genre-horror_predator_stalking_ai.gd)
A sophisticated "Stalker" AI inspired by *Alien: Isolation*. Uses a dual-brain system: a cheating "Director" that guides it toward the player, and an honest "Senses" brain that must actually see/hear the player to trigger an attack.


## NEVER Do

- **NEVER maintain 100% tension at all times** — Constant stress leads to exhaustion and player "numbing." Use a **Sawtooth Pacing** model: build tension, hit a peak (scare), and provide a dedicated "Relief" period (e.g., a Safe Room or Quiet area) before building up again.
- **NEVER allow AI to detect the player instantly** — Instant snapshots feel like "unfair cheating" to the player. Implement a **Suspicion Meter** or a 1-3s reaction window before the AI enters full aggression.
- **NEVER make environments Pitch Black** — Total darkness is frustrating for navigation. Use rim lighting, weak "ambient glow," or a limited-battery flashlight. Darkness should obscure *threats*, not the *floor*.
- **NEVER rely on jump-scares as the primary source of horror** — Jump-scares are a startle response, not true dread. Use atmosphere, spatial audio cues, and the *anticipation* of a threat to build genuine horror.
- **NEVER grant the player unlimited resources** — Survival horror relies on **Scarcity**. Limited flashlight batteries, rare ammo, and slow healing animations force the player to make stressful choices.
- **NEVER use predictable AI paths** — An enemy that follows a perfect loop is just a puzzle, not a threat. Use the `Director` to periodically "hint" a new destination near the player to keep the AI relevant.

---

## The Director System (Pacing)
The Director is an invisible AutoLoad script that:
- Tracks the player's "Stress Level" (based on movement, proximity to monsters, and health).
- If Stress is too high, it sends the Monster away (Relief phase).
- If Stress is too low, it guides the Monster to investigate a room NEAR the player.

## Sensory AI Components
- **Vision**: Uses `intersect_ray` with vertical FOV checks.
- **Hearing**: Detects "Noise Events" emitted by the player (e.g., Sprinting, Dropping objects).
- **Suspicion**: A state between `IDLE` and `CHASING` where the AI searches the last known location.

## Atmosphere and Lighting
- **Volumetric Fog**: Use the `WorldEnvironment` node to create dynamic mist that can be thickened during high-tension scenes.
- **Dynamic Shadows**: Essential for hiding threats. Use high-quality shadows for the player's primary light source.
- **Audio Distortion**: Use `AudioServer` effects (Low-Pass Filter, Reverb) to simulate the player's internal heartbeat or panic during high-stress encounters.

## Interactive Objects
- **Hiding Places**: Use `Area3D` triggers (Lockers, Under-beds) that disable the player's collision and switch the camera to a "Peeking" view.
- **Door Leaning**: A common horror mechanic allowing players to peek around corners without fully exposing their hitbox.

## Reference
- [Godot Docs: 3D Lighting and Shadows](https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html#lighting)
- [GDC: The AI of Alien Isolation](https://www.youtube.com/watch?v=P72fOxyJST8)
