---
name: godot-genre-horror
description: "Expert blueprint for horror games including tension pacing (sawtooth wave: buildup/peak/relief), Director system (macro AI controlling pacing), sensory AI (vision/sound detection), sanity/stress systems (camera shake, audio distortion), lighting atmosphere (volumetric fog, dynamic shadows), and \"dual brain\" AI (cheating director + honest senses). Use for psychological horror, survival horror, or atmospheric games. Trigger keywords: horror_game, tension_pacing, director_system, sensory_perception, sanity_system, volumetric_fog, AI_reaction_time."
---

# Genre: Horror

Expert blueprint for horror games balancing tension, atmosphere, and player agency.

## NEVER Do

- **NEVER maintain constant tension** — Players get numb. Enforce "Relief" periods (safe rooms, calm music) between scares for sawtooth pacing.
- **NEVER make AI instantly detect player** — Instant detection feels unfair. Give AI 1-3s reaction time or "suspicion meter" before full aggro.
- **NEVER make environments too dark** — Darkness should obscure *details*, not *navigation*. Use rim lighting or weak flashlight.
- **NEVER rely on jump scares alone** — Jump scares lose effectiveness after 2-3 uses. Build dread through atmosphere and anticipation.
- **NEVER give players too much power** — Unlimited ammo/healing breaks horror. Scarcity creates tension (limited battery, health, ammo).
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [predator_stalking_ai.gd](scripts/predator_stalking_ai.gd)
AI that stalks player while avoiding line-of-sight. Checks player view cone via dot product, retreats perpendicular when detected, maintains stalking distance.

---

## Core Loop
1.  **Explore**: Player navigates a threatening environment.
2.  **Sense**: Player hears/sees signs of danger.
3.  **React**: Player hides, runs, or fights (disempowered combat).
4.  **Survive**: Player reaches safety or solves a puzzle.
5.  **Relief**: Brief moment of calm before tension builds again.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Atmosphere | `godot-3d-lighting`, `godot-audio-systems` | Volumetric fog, dynamic shadows, spatial audio |
| 2. AI | `godot-state-machine-advanced`, `godot-navigation-pathfinding` | Hunter AI, sensory perception |
| 3. Player | `characterbody-3d` | Leaning, hiding, slow movement |
| 4. Scarcity | `godot-inventory-system` | Limited battery, ammo, health |
| 5. Logic | `game-manager` | The "Director" system controlling pacing |

## Architecture Overview

### 1. The Director System (Macro AI)
Controls the pacing of the game to prevent constant exhaustion.

```gdscript
# director.gd
extends Node

enum TensionState { BUILDUP, PEAK, RELIEF, QUIET }
var current_tension: float = 0.0
var player_stress_level: float = 0.0

func _process(delta: float) -> void:
    match current_tension_state:
        TensionState.BUILDUP:
            current_tension += 0.5 * delta
            if current_tension > 75.0:
                 trigger_event()
        TensionState.RELIEF:
            current_tension -= 2.0 * delta

func trigger_event() -> void:
    # Hints the Monster AI to check a room NEAR the player, not ON the player
    monster_ai.investigate_area(player.global_position + Vector3(randf(), 0, randf()) * 10)
```

### 2. Sensory Perception (Micro AI)
The monster's actual senses.

```gdscript
# sensory_component.gd
extends Area3D

signal sound_heard(position: Vector3, volume: float)
signal player_spotted(position: Vector3)

func check_vision(target: Node3D) -> bool:
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(global_position, target.global_position)
    var result = space_state.intersect_ray(query)
    
    if result and result.collider == target:
        return true
    return false
```

### 3. Sanity / Stress System
Distorting the world based on fear.

```gdscript
# sanity_manager.gd
func update_sanity(amount: float) -> void:
    current_sanity = clamp(current_sanity + amount, 0.0, 100.0)
    # Effect: Camera Shake
    camera_shake_intensity = (100.0 - current_sanity) * 0.01
    # Effect: Audio Distortion
    audio_bus.get_effect(0).drive = (100.0 - current_sanity) * 0.05
```

## Key Mechanics Implementation

### Pacing (The Sawtooth Wave)
Horror needs peaks and valleys.
1.  **Safety**: Save room.
2.  **Unease**: Strange noise, lights flicker.
3.  **Dread**: Monster is known to be close.
4.  **Terror**: Chase sequence / Combat.
5.  **Relief**: Escape to Safety.

### The "Dual Brain" AI
*   **Director (All-knowing)**: Cheats to keep the alien relevant (teleports it closer if far away, guides it to player's general area).
*   **Alien (Senses only)**: Honest AI. Must actually see/hear the player to attack.

## Godot-Specific Tips

*   **Volumetric Fog**: Use `WorldEnvironment` -> `VolumetricFog` for instant atmosphere. Animate `density` for dynamic dread.
*   **Light Occluder 2D**: For 2D horror, shadow casting is essential.
*   **AudioBus**: Use `Reverb` and `LowPassFilter` on the Master bus, controlled by scripts, to simulate "muffled" hearing when scared or hiding.
*   **AnimationTree**: Use blend spaces to smooth transitions between "Sneak", "Walk", and "Run" animations.

## Common Pitfalls

1.  **Constant Tension**: Player gets numb. **Fix**: Enforce "Relief" periods where nothing happens.
2.  **Frustrating AI**: AI sees player instantly. **Fix**: Give AI a "reaction time" or "suspicion meter" before full aggro.
3.  **Too Dark**: Player can't see anything. **Fix**: Darkness should obscure *details*, not *navigation*. Use rim lighting or a weak flashlight.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
