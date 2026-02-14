> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Fighting Game**. Accessed via Godot Master.

# Genre: Fighting Game

Expert blueprint for building 2D and 3D fighting games. Focuses on frame-perfect execution, complex input buffering (Motion Commands), and robust collision systems (Hitboxes/Hurtboxes).

## Available Scripts

### [fighting_input_buffer.gd](../scripts/godot-genre-fighting_fighting_input_buffer.gd)
A frame-locked input engine essential for competitive fighters. Polled at a fixed 60fps, this script manages an 8-15 frame buffer and includes fuzzy detection for motion commands like Quarter-Circle Forward (QCF) or Dragon Punch (DP).

### [hitbox_component.gd](../scripts/godot-genre-fighting_hitbox_component.gd)
A professional hitbox/hurtbox utility. Defines layered collision zones (Head, High, Low, Throw) and handles the "Hit Confirmation" logic, including damage application and hitstun signal emission.


## NEVER Do

- **NEVER use variable framerates** — Fighting games MUST be deterministic. Do not rely on `_process(delta)` for gameplay logic. Implement a fixed custom loop or a strict `_physics_process(delta)` where 1 frame = exactly 16.66ms.
- **NEVER skip Input Buffering** — If a player presses "P" and "K" at slightly different times, the game must be lenient. A **5-10 frame buffer** is mandatory to ensure inputs feel responsive rather than "dropped."
- **NEVER use standard Physics for Hit Detection** — Standard `Area2D` or `CollisionShape3D` behavior is too jittery for frame-perfect fighters. Use a custom **Box-to-Box overlap** system with specific state-based activation.
- **NEVER skip "Damage Scaling"** — Infinite or near-infinite combos ruin competitive play. Every subsequent hit in a combo should reduce the damage of the next (e.g., Hit 1 = 100%, Hit 2 = 90%, Hit 3 = 82%).
- **NEVER make all attacks "Safe on Block"** — If every move leaves the attacker with an advantage, defense is impossible. High-reward moves MUST have large "Recovery" windows where the attacker can be punished.
- **NEVER use simple parenting for character flip** — Just flipping `scale.x = -1` can break hitbox positioning and physics. Use a dedicated `Visuals` node and adjust the hitbox coordinates programmatically.

---

## The Frame Data Model
Every move should be defined by three phases:
1. **Startup**: The wind-up phase. No damage dealt.
2. **Active**: The window where the Hitbox can collide with a Hurtbox.
3. **Recovery**: The cool-down phase where the player is vulnerable.

## Hitboxes and Hurtboxes
- **Hurtbox**: Where you can be hit (Your body).
- **Hitbox**: Your weapon or fist that deals damage.
- **Proximity Box**: Activates when the opponent is close, forcing a "Blocking" state.

## Input: Motion Command Detection
To detect a "Quarter Circle Forward":
1. Store a history of the last 20 frames of directional inputs.
2. Look for the specific sequence: `DOWN` -> `DOWN_FORWARD` -> `FORWARD`.
3. If the sequence is found within the last 15 frames, trigger the "Special Move."

## Advantage and Disadvantage
- **On Hit**: Does the attacker recover before the defender exits hitstun? (Frame Advantage).
- **On Block**: Does the defender recover first? (The attacker is "Punishable").

## Combo Systems
- **Cancel Hierarchy**: Allow players to cancel a "Normal" move into a "Special" move during the active frames.
- **Hitstun Decay**: Each subsequent hit in a combo should reduce the duration of the next hit's stun, eventually allowing the opponent to fall out of the combo safely.

## Reference
- [The Frame Data Bible (EventHubs)](https://www.eventhubs.com/guides/2007/oct/21/street-fighter-4-frame-data-and-glossary/)
- [Godot Docs: Handling Deterministic Input](https://docs.godotengine.org/en/stable/tutorials/inputs/input_event.html)
