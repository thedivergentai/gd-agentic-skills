> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Battle Royale**. Accessed via Godot Master.

# Genre: Battle Royale

Expert blueprint for building large-scale Battle Royale games. Focuses on networking optimizations for 100+ players, dynamic circle/storm mechanics, and authoritative deployment systems.

## Available Scripts

### [storm_system.gd](../scripts/godot-genre-battle-royale_storm_system.gd)
A professional-grade shrinking zone manager. Handles phase-based timing, interpolates the storm's center and radius towards a new safe zone, and calculates scalable damage-over-time for players caught in the "Storm."

### [kill_feed_bus.gd](../scripts/godot-genre-battle-royale_kill_feed_bus.gd)
A centralized signal bus for eliminations. Manages the global kill-feed UI, tracks player elimination counts for end-of-match statistics, and provides an easy interface for any offensive system to report a kill.


## NEVER Do

- **NEVER sync all 100 players every frame** — Sending full packet updates for 100 players 60 times a second will crash the network. Use a **Relevancy System**: only sync high-frequency data for players within a 100m radius. Distant players should update at a much lower frequency (e.g., 5-10Hz).
- **NEVER pick a fully random center for the Safe Zone** — If the new circle does not overlap with the previous one, players will find it impossible to cross the map in time. Target centers must be clamped such that the new circle is always completely contained within the current one.
- **NEVER use client-side Hit Detection** — Battle Royales are highly competitive and prone to cheating. The Client should only send "I fired a shot at Angle X"; the **Authoritative Server** must validate if the shot hit an enemy based on the server-side positions of all players.
- **NEVER spawn loot without Object Pooling** — Instantiating 5,000 guns and ammo boxes across a large map will cause a major garbage collection (GC) spike at game start. Use a **Loot Pool** and simply enable/disable the visibility and collision of pre-instantiated items.
- **NEVER ignore `VisibilityNotifier3D`** — Distant players that are not visible should have their `AnimationPlayer`, `_process()`, and heavy logic scripts disabled to save CPU cycles. This is the single most important optimization for 100-player Battle Royales.
- **NEVER allow "Storm Tunneling"** — If your server tick is too low, players can sometimes move so fast they bypass the storm's edge checks. Always use a distance-to-center calculation rather than a simple collision perimeter.

---

## Networking Optimization: Snapshot Interpolation
Because BR servers typically run at low tick rates (20-30Hz), movement will look jittery.
- **Solution**: The Client should maintain a small "Buffer" (e.g., 100ms) of server snapshots.
- Instead of snapping to the newest position, the client smoothly interpolates between `State A` and `State B` from the history.

## Deployment System (The Jump)
1. **The Plane**: A shared `VehicleBody` or kinematic object following a `Path3D`.
2. **Eject**: When the player hits "Space," they are detached and enter a high-speed gravity state.
3. **Parachute**: At a set altitude, the player's gravity and velocity are capped to allow for controlled gliding toward a landing spot.

## Loot Tables and Rarity
Use `Resource` files for loot:
- **WeaponData**: Includes damage, fire rate, and **Rarity Enum** (Common, Rare, Epic, Legendary).
- **Spawn Logic**: Higher rarity items have a lower percentage weight in the `LootManager` roll table.

## Storm Visualization (Shader)
Don't use thousands of wall nodes.
- Use a single, massive **CubeMesh** with an **Inverse Cylinder Shader**.
- The shader renders a "Wall of Fog" based on a `global_uniform` center and radius provided by the `StormSystem`.

## Relevancy and Culling
To handle the scale:
- **High-Prio**: 0-50m (Full sync, 60Hz)
- **Mid-Prio**: 50-200m (Interp, 20Hz)
- **Low-Prio**: 200m+ (Basic position only, 5Hz)
- **Culled**: Behind player or >500m (No sync).

## Reference
- [Godot Docs: High-level Multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)
- [GDC: Networking for Apex Legends](https://www.youtube.com/watch?v=S0TOf794iDs)
