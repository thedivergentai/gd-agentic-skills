---
name: godot-genre-moba
description: "Expert blueprint for MOBA games including lane logic (minion wave spawning every 30s), tower aggro priority (hero attacking ally over minion over hero), click-to-move controls (RTS-style raycasting), hero ability systems (QWER cooldowns, mana cost), fog of war (SubViewport projections), and authoritative networking (server validates damage). Use for competitive 5v5 or arena games. Trigger keywords: MOBA, lane_manager, minion_waves, tower_aggro, click_to_move, ability_cooldowns, fog_of_war, comeback_mechanics."
---

# Genre: MOBA (Multiplayer Online Battle Arena)

Expert blueprint for MOBAs emphasizing competitive balance and strategic depth.

## NEVER Do

- **NEVER client-side damage calculation** — Client says "I cast Q at direction V", server calculates damage. Otherwise hacking trivializes game.
- **NEVER ignore snowballing** — Winning team gets too strong. Implement comeback mechanics (kill bounties, catchup XP).
- **NEVER pathfind all minions every frame** — 100+ minions cause lag. Time-slice pathfinding over multiple frames.
- **NEVER sync position every frame** — Use client-side prediction. Sync position corrections at 10-20Hz, not 60Hz.
- **NEVER forget minion avoidance** — Enable NavigationAgent3D.avoidance_enabled so minions flow around each other, not stack.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [skill_shot_indicator.gd](scripts/skill_shot_indicator.gd)
Mouse-following skillshot telegraph. Draws rectangular indicator, rotates toward cursor in _physics_process for ability range preview.

### [tower_priority_aggro.gd](scripts/tower_priority_aggro.gd)
Tower target priority stack: heroes-attacking-allies > minions > heroes. Deterministic targeting with closest-distance tiebreaker.

---

## Core Loop
1.  **Lane**: Player farms minions for gold/XP in a designated lane.
2.  **Trade**: Player exchanges damage with opponent hero.
3.  **Gank**: Player roams to other lanes to surprise enemies.
4.  **Push**: Team destroys towers to open the map.
5.  **End**: Destroy the enemy Core/Nexus.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Control | `rts-controls` | Right-click to move, A-move, Stop |
| 2. AI | `godot-navigation-pathfinding` | Minion waves, Tower aggro logic |
| 3. Combat | `godot-ability-system`, `godot-rpg-stats` | QWER abilities, cooldowns, scaling |
| 4. Network | `godot-multiplayer-networking` | Authority, lag compensation, prediction |
| 5. Map | `godot-3d-world-building` | Lanes, Jungle, River, Bases |

## Architecture Overview

### 1. Lane Manager
Spawns waves of minions periodically.

```gdscript
# lane_manager.gd
extends Node

@export var lane_path: Path3D
@export var spawn_interval: float = 30.0
var timer: float = 0.0

func _process(delta: float) -> void:
    timer -= delta
    if timer <= 0:
        spawn_wave()
        timer = spawn_interval

func spawn_wave() -> void:
    # Spawn 3 Melee, 3 Ranged, 1 Cannon (every 3rd wave)
    for i in range(3):
        spawn_minion(MeleeMinion, lane_path)
        await get_tree().create_timer(1.0).timeout
```

### 2. Minion AI
Simple but follows strict rules.

```gdscript
# minion_ai.gd
extends CharacterBody3D

enum State { MARCH, COMBAT }
var current_target: Node3D

func _physics_process(delta: float) -> void:
    match state:
        State.MARCH:
            move_along_path()
            scan_for_enemies()
        State.COMBAT:
            if is_instance_valid(current_target):
                attack(current_target)
            else:
                state = State.MARCH
```

### 3. Tower Aggro Logic
The most misunderstood mechanic by new players.

```gdscript
# tower.gd
func _on_aggro_check() -> void:
    # Priority 1: Enemy Hero attacking Ally Hero
    var hero_target = check_for_hero_aggro()
    if hero_target:
        current_target = hero_target
        return

    # Priority 2: Closest Minion
    # Priority 3: Closest Hero
```

## Key Mechanics Implementation

### Click-to-Move (RTS Style)
Raycasting from camera to terrain.

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("move"):
        var result = raycast_from_mouse()
        if result:
            nav_agent.target_position = result.position
```

### Ability System (Data Driven)
Defining "Fireball" or "Hook" without unique scripts for everything.

```gdscript
# ability_data.gd
class_name Ability extends Resource
@export var cooldown: float
@export var mana_cost: float
@export var damage: float
@export var effect_scene: PackedScene
```

## Godot-Specific Tips

*   **NavigationAgent3D**: Use `avoidance_enabled` for minions so they flow around each other like water, rather than stacking.
*   **MultiplayerSynchronizer**: Sync Health, Mana, and Cooldowns. Do NOT sync position every frame if using Client-Side Prediction (advanced).
*   **Fog of War**: Use a `SubViewport` with a fog texture. Paint "holes" in the texture where allies are. Project this texture onto the terrain shader.

## Common Pitfalls

1.  **Snowballing**: Winning team gets too strong too fast. **Fix**: Implement "Comeback XP/Gold" mechanisms (bounties).
2.  **Pathfinding Lag**: 100 minions pathing every frame. **Fix**: Distribute pathfinding updates over multiple frames (Time Slicing).
3.  **Hacking**: Client says "I dealt 1000 damage". **Fix**: Client says "I cast Spell Q at Direction V". Server calculates damage.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
