> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Shooter (FPS/TPS)**. Accessed via Godot Master.

# Genre: Shooter (FPS/TPS)

Expert blueprint for high-performance gunplay in First-Person and Third-Person shooters. Covers hitscan vs. projectile ballistics, procedural recoil patterns, layered weapon audio, and multiplayer lag compensation patterns.

## Available Scripts

### [advanced_weapon_controller.gd](../scripts/godot-genre-shooter_advanced_weapon_controller.gd)
A professional-grade weapon implementation. Features deterministic recoil patterns, bloom (accuracy loss over time), dual hitscan/projectile firing modes, and optimized raycasting logic.


## NEVER Do

- **NEVER use `_process()` for weapon hit detection** — Aiming and firing occur on the physics timeline. All raycasts and projectile motion MUST happen in `_physics_process()` to maintain frame-rate independent accuracy.
- **NEVER apply recoil to the physical weapon model transform** — Recoil is a visual and mechanical system that affects **Camera Rotation** (kick) and **Weapon Bloom** (spread), not just the gun's position in 3D space.
- **NEVER use a single `AudioStreamPlayer` for gunfire** — Real guns produce a complex soundscape. Use a **Layered Audio** approach: a punchy "click" for mechanics, a loud "pop" for the shot, and a long "reverb tail" for environmental echo.
- **NEVER synchronize every bullet over the network** — In multiplayer, do not `rpc()` the position of every bullet per frame. Use **Client-Side Prediction** to show local tracers immediately, and send only the initial "Fire" event for the server to validate.
- **NEVER use `Area3D` overlap for high-speed hit detection** — Areas are useful for triggers, but instilling ballistics with them is 100x slower than using a `PhysicsDirectSpaceState3D.intersect_ray()`.
- **NEVER hardcode weapon statistics inside the logic script** — Weapon data (Damage, Recoil, Fire Rate) should live in a `Resource` (e.g., `WeaponData.tres`). This allows designers to balance the game without touching the code.
- **NEVER trust the client for hit registration in multiplayer** — Never allow a client to send "I hit Player B" to the server. The server must be the ultimate authority, performing its own raycast to validate the shot.

---

## Ballistics: Hitscan vs. Projectile
- **Hitscan**: Instant hit. Ideal for pistols, rifles, and high-velocity snipers. Uses `intersect_ray`.
- **Projectile**: Physical travel time. Ideal for rockets, grenades, and slow-moving projectiles. Uses `CharacterBody3D` with manual velocity integration.

## Recoil and Bloom Patterns
- **Recoil Pattern**: A series of Vector2 offsets applied to the player's view over a sustained burst (e.g., the "T" or "7" shape spray).
- **Bloom**: The widening of the weapon's accuracy cone during rapid fire. Visualized by expanding the crosshair UI.

## Aim Assist Logic
For gamepads, implement subtle helpers:
- **Friction**: Slowing down the player's sensitivity when the crosshair is near an enemy.
- **Magnetism**: Pulling the crosshair slightly toward the enemy's center-of-mass during a shot.

## Weapon Feel ("The Juice")
- **Screen Shake**: A brief, intense camera shake on every shot.
- **FOV Punch**: A subtle, rapid FOV increase/decrease on firing.
- **Muzzle Flash**: Light and particle emitters that trigger for exactly 1 or 2 frames.
- **Casing Ejection**: Spawning physics-based bullet shells using `CPUParticles3D` or object pooling.

## Reference
- [Godot Docs: Ray-casting](https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html)
- [Valve Wiki: Lag Compensation](https://developer.valvesoftware.com/wiki/Source_Multiplayer_Networking#Lag_compensation)
