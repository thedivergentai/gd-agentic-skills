---
name: godot-genre-battle-royale
description: "Expert blueprint for Battle Royale games including shrinking zone/storm mechanics (phase-based, damage scaling), large-scale networking (relevancy, tick rate optimization), deployment systems (plane, freefall, parachute), loot spawning (weighted tables, rarity), and performance optimization (LOD, occlusion culling, object pooling). Use for multiplayer survival games or last-one-standing formats. Trigger keywords: battle_royale, zone_shrink, storm_damage, deployment_system, loot_spawn, networking_optimization, relevancy_system, snapshot_interpolation."
---

# Genre: Battle Royale

Expert blueprint for Battle Royale games with zone mechanics, large-scale networking, and survival gameplay.

## NEVER Do

- **NEVER sync all 100 players every frame** — Use relevancy system: only sync players within visual range. Far players update at 4Hz, nearby at 20Hz+.
- **NEVER make zone center fully random** — New circle must overlap significantly with old circle, or players teleport. Limit offset to `current_radius - target_radius`.
- **NEVER use client-side hit detection** — Client says "I shot at direction X", Server validates "Did it hit?". Prevents cheating.
- **NEVER spawn loot without pooling** — 1000+ loot items cause GC spikes. Pool loot pickups and reuse instances.
- **NEVER forget VisibilityNotifier3D for distant players** — Disable `_process()` and AnimationPlayer for players behind or far away. Saves 60-80% CPU.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [kill_feed_bus.gd](scripts/kill_feed_bus.gd)
Global elimination signal bus with match stat tracking. Single emission point for UI/logging, sorted killer rankings for end-game summary.

### [storm_system.gd](scripts/storm_system.gd)
Dynamic zone shrinking with damage interpolation. Tweens center/radius smoothly, scales damage by zone size for end-game intensity.

---

## Core Loop
1.  **Deploy**: Player chooses a landing spot from an air vehicle.
2.  **Loot**: Player scavenges weapons and armor.
3.  **Move**: Player runs to the safe zone to avoid taking damage.
4.  **Engage**: Player fights others they encounter.
5.  **Survive**: Player attempts to be the last one standing.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Net | `godot-multiplayer-networking` | Authoritative server, lag compensation |
| 2. Map | `godot-3d-world-building`, `level-of-detail` | Large terrain, chunking, distant trees |
| 3. Items | `godot-inventory-system` | Managing backpack, attachments, armor |
| 4. Combat | `shooter-mechanics`, `ballistics` | Projectile physics, damage calculation |
| 5. Logic | `game-manager` | Managing the Storm/Zone state |

## Architecture Overview

### 1. The Zone Manager (The Storm)
Manages the shrinking safe area.

```gdscript
# zone_manager.gd
extends Node

@export var phases: Array[ZonePhase]
var current_phase_index: int = 0
var current_radius: float = 2000.0
var target_radius: float = 2000.0
var center: Vector2 = Vector2.ZERO
var target_center: Vector2 = Vector2.ZERO
var shrink_speed: float = 0.0

func start_next_phase() -> void:
    var phase = phases[current_phase_index]
    target_radius = phase.end_radius
    # Pick new center WITHIN current circle but respecting new radius
    var random_angle = randf() * TAU
    var max_offset = current_radius - target_radius
    var offset = Vector2.RIGHT.rotated(random_angle) * (randf() * max_offset)
    target_center = center + offset
    
    shrink_speed = (current_radius - target_radius) / phase.shrink_time

func _process(delta: float) -> void:
    if current_radius > target_radius:
        current_radius -= shrink_speed * delta
        center = center.move_toward(target_center, (shrink_speed * delta) * (center.distance_to(target_center) / (current_radius - target_radius)))
```

### 2. Loot Spawner
Efficiently populating the world.

```gdscript
# loot_manager.gd
func spawn_loot() -> void:
    for spawn_point in get_tree().get_nodes_in_group("loot_spawns"):
        if randf() < spawn_point.spawn_chance:
            var item_id = loot_table.roll_item()
            var loot_instance = loot_scene.instantiate()
            loot_instance.setup(item_id)
            add_child(loot_instance)
```

### 3. Deployment System
Transitioning from plane to ground.

```gdscript
# player_controller.gd
enum State { IN_PLANE, FREEFALL, PARACHUTE, GROUNDED }

func _physics_process(delta: float) -> void:
    match current_state:
        State.FREEFALL:
            velocity.y = move_toward(velocity.y, -50.0, gravity * delta)
            move_and_slide()
            if position.y < auto_deploy_height:
                deploy_parachute()
```

## Key Mechanics Implementation

### Zone Damage
Checking if player is outside the circle.

```gdscript
func check_zone_damage() -> void:
    var dist = Vector2(global_position.x, global_position.z).distance_to(ZoneManager.center)
    if dist > ZoneManager.current_radius:
        take_damage(ZoneManager.dps * delta)
```

### Networking Optimization
You cannot sync 100 players every frame.
*   **Relevancy**: Only send updates for players within visual range.
*   **Frequency**: Update far-away players at 4Hz, nearby at 20Hz+ (Server Tick).
*   **Snapshot Interpolation**: Client buffers headers to play them back smoothly.

## Godot-Specific Tips

*   **MultiplayerSynchronizer**: Use `replication_interval` to lower bandwidth for distant objects.
*   **VisibilityNotifier3D**: Critical. Disable `_process` and AnimationPlayer for players behind you or far away.
*   **Occlusion Culling**: Essential for large maps with buildings. Bake occlusion data.
*   **HLOD**: Use Hierarchical Level of Detail for terrain and large structures.

## Common Pitfalls

1.  **Too Main Loot**: Too much loot causes lag. **Fix**: Use object pooling for loot pickups.
2.  **Camping**: Players hide forever. **Fix**: The Zone forces movement. Also, anti-camping mechanics like "scan reveals" (optional).
3.  **Cheating**: Client-side hit detection. **Fix**: Authoritative server logic. Client says "I shot at direction X", Server calculates "Did it hit?".


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
