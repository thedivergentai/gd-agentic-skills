---
name: godot-genre-horror
description: "Expert blueprint for horror games including tension pacing (sawtooth wave: buildup/peak/relief), Director system (macro AI controlling pacing), sensory AI (vision/sound detection), sanity/stress systems (camera shake, audio distortion), lighting atmosphere (volumetric fog, dynamic shadows), and \"dual brain\" AI (cheating director + honest senses). Use for psychological horror, survival horror, or atmospheric games. Trigger keywords: horror_game, tension_pacing, director_system, sensory_perception, sanity_system, volumetric_fog, AI_reaction_time."
---

# Genre: Horror

Expert blueprint for horror games balancing tension, atmosphere, and player agency.

## NEVER Do (Expert Anti-Patterns)

### Atmosphere & Tension
- NEVER maintain 100% tension at all times; strictly use a **Sawtooth Pacing** model (buildup → peak/scare → dedicated relief period) to prevent player "numbing" and exhaustion.
- NEVER rely on jump-scares as the primary source of horror; focus on atmosphere, spatial audio cues, and the *anticipation* of a threat to build genuine dread.
- NEVER make environments pitch black to the point of frustrating navigation; darkness should obscure *threats* (details), not the *floor*. Use rim lighting or a limited-battery flashlight.
- NEVER grant the player unlimited resources; survival horror relies on **Scarcity**. Limited battery, rare ammo, and slow animations are mandatory to force stressful decision-making.

### AI & Senses
- NEVER allow AI to detect the player instantly; implement a **Suspicion Meter** or a 1-3s reaction window before the AI enters full aggression to avoid "unfair cheating" feel.
- NEVER use predictable AI paths; an enemy on a perfect loop is a puzzle, not a predator. Use the **Director** to periodically "hint" a new destination near the player.
- NEVER use Area3D overlap signals for instant, frame-perfect Line-of-Sight (LoS) checks; use nodeless raycasting via `PhysicsDirectSpaceState3D.intersect_ray()` for fixed-physics sync.
- NEVER calculate complex AI vision or pathfinding for monsters far outside the camera's frustum; use `VisibleOnScreenNotifier3D` to disable processing logic.
- NEVER leave navigation avoidance layers unconfigured on chasing monsters; explicitly assign avoidance masks to prevent visual "stacking" in tight corridors.

### Technical & Scarcity
- NEVER use the visual SceneTree (like GridContainer children) as the source of truth for inventory; strictly maintain a typed memory structure like `Dictionary[StringName, Resource]`.
- NEVER rely on instantiating standard Nodes to store base item stats/definitions; use custom `Resource` scripts to reduce memory overhead and allow direct Inspector editing.
- NEVER forget to call `duplicate(true)` on an item's Resource when adding to inventory; if items have mutable states (ammo/durability), you will overwrite the global resource otherwise.
- NEVER parse massive JSON save files synchronously; strictly offload heavy parsing to the `WorkerThreadPool` to prevent auto-save freezes.
- NEVER use standard strings for hot-path IDs (states, item types); strictly use `StringName` (&"chasing") for pointer-speed comparisons.
- NEVER evaluate exact floating-point equality (sanity == 0.0); strictly use `is_equal_approx()` or threshold checks for deterministic triggers.
- NEVER write screen-reading shaders expecting Godot 3 `SCREEN_TEXTURE`; strictly use `sampler2D` with `hint_screen_texture`.
- NEVER instantiate detailed monster meshes or lights without culling; strictly configure `visibility_range` for automatic HLOD efficiency.
- NEVER rely on AnimationPlayer for random flickering; use `Tween` for programmatic, clean energy manipulation.
- NEVER load heavy scare scenes or 4K textures synchronously via `load()`; strictly use `ResourceLoader.load_threaded_request()` to prevent frame stalls.
- NEVER scale CollisionShape3D non-uniformly; strictly adjust internal shape resource parameters (radius, height) to prevent erratic physics.

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [predator_stalking_ai.gd](scripts/predator_stalking_ai.gd) - Sophisticated "Stalker" AI using dual-brain logic (Director + Senses) and player view-cone avoidance.
- [director_pacing.gd](scripts/director_pacing.gd) - Invisible orchestrator managing the "Sawtooth" tension wave and relief periods.

### Modular Components
- [monster_los_check.gd](scripts/monster_los_check.gd) - Physics-synced raycasting for high-performance visibility checks.
- [flashlight_flicker.gd](scripts/flashlight_flicker.gd) - Procedural light interference for atmospheric tension.
- [inventory_data_storage.gd](scripts/inventory_data_storage.gd) - Typed data structure for sparse resource management.
- [async_scare_loader.gd](scripts/async_scare_loader.gd) - Threaded resource loading for hitch-free jump-scares.
- [spatial_noise_emitter.gd](scripts/spatial_noise_emitter.gd) - Shape-based sound sensing for sensory AI.
- [item_state_duplicator.gd](scripts/item_state_duplicator.gd) - Deep duplication for managing unique weapon/item states.
- [fog_claus_intensifier.gd](scripts/fog_claus_intensifier.gd) - Volumetric fog manipulation for dread buildup.
- [offscreen_logic_suspender.gd](scripts/offscreen_logic_suspender.gd) - Culling logic for AI processing outside camera view.
- [sanity_shader_manager.gd](scripts/sanity_shader_manager.gd) - Instance-uniform driven distortion effects.
- [optimized_horror_state_machine.gd](scripts/optimized_horror_state_machine.gd) - High-speed predator behavior logic.

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
