> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: MOBA**. Accessed via Godot Master.

# Genre: MOBA (Multiplayer Online Battle Arena)

Expert blueprint for building competitive MOBA games. Focuses on the "Lane-Minion-Tower" loop, skill-shot targeting systems, and authoritative server-side combat logic.

## Available Scripts

### [skill_shot_indicator.gd](../scripts/godot-genre-moba_skill_shot_indicator.gd)
A mouse-driven targeting system for abilities. Visualizes range, width, and direction for "skill-shot" abilities (e.g., hooks, projectiles, or lines of effect) using `_physics_process` for responsive aiming.

### [tower_priority_aggro.gd](../scripts/godot-genre-moba_tower_priority_aggro.gd)
Advanced AI logic for defensive towers. Implements the complex "Tower Priority" rules used in competitive MOBA games (Hero-on-Hero Priority > Minion Wave > Hero).


## NEVER Do

- **NEVER trust the client for damage calculation** — The client should only send Input (e.g., "Cast Ability Q at Vector V"). The **Server** must perform the overlap checks and calculate the damage to prevent basic hacking.
- **NEVER use expensive pathfinding for all minions every frame** — With 100+ minions per lane, calling `get_next_path_position()` every frame will lag the physics engine. Use **Time Slicing** to spread pathfinding updates across multiple frames.
- **NEVER sync unit positions at 60Hz** — For games with many units like MOBAs, use `MultiplayerSynchronizer` at a lower tick rate (10-20Hz) and use **Interpolation/Client-Side Prediction** to keep the movement looking smooth.
- **NEVER ignore "Snowballing" mechanics** — If the winning team gains a lead and there are no comeback mechanics (like Kill Bounties or Catch-up XP), the game becomes boring after 10 minutes. Always design for parity.
- **NEVER use `_process()` for Minion AI logic** — This is a physics-driven genre. Minions should use `_physics_process()` to interact with `NavigationAgent3D` and avoid stacking behavior through `avoidance_enabled`.
- **NEVER forget to handle Tower "Dive" logic** — Towers must switch targets immediately if an enemy Hero damages an allied Hero within the tower's range. This "protection" mechanic is critical for the genre's balance.

---

## Click-to-Move Controls
1. **Raycast**: Project a ray from the camera through the mouse position into the 3D world.
2. **Terrain Collision**: Identify the point on the "Ground" layer where the ray hit.
3. **Navigation**: Set the `NavigationAgent3D.target_position` to that point.

## Lane Management and Minion Waves
- **Spawner**: Triggers a wave of 6 minions every 30 seconds.
- **Pathing**: Minions follow a `Path3D` toward the enemy base.
- **State Machine**:
  - `MARCHING`: Walking along the path.
  - `ENGAGED`: Attacking the first enemy unit encountered.

## Ability Systems (QWER)
- **Data-Driven**: Use `Resource` files to define cooldowns, mana costs, and base damage.
- **Casting States**: Idle -> Pre-cast (Telegraph) -> Active (Hitbox) -> Recovery (Backswing).

## Fog of War Pattern
1. Use a high-resolution `Viewport` to render a "Visibility Map."
2. Allied units draw white circles onto this map.
3. A full-screen shader uses this map as a transparency mask (alpha) over a dark "Fog" overlay.

## Performance Tuning (100+ Units)
- Use **Groups** for lightning-fast aggro checks: `get_tree().get_nodes_in_group("enemies")`.
- Disable collision and processing for dead units immediately; do not wait for the death animation to finish.

## Reference
- [Godot Docs: 3D Navigation](https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html)
- [MOBA Wiki: Tower Aggro Mechanics](https://leagueoflegends.fandom.com/wiki/Turret#Aggro)
