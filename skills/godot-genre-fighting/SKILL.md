---
name: godot-genre-fighting
description: "Expert blueprint for fighting games including frame data (startup/active/recovery frames, advantage on hit/block), hitbox/hurtbox systems, input buffering (5-10 frames), motion input detection (QCF, DP), combo systems (damage scaling, cancel hierarchy), character states (idle/attacking/hitstun/blockstun), and rollback netcode. Based on FGC competitive design. Trigger keywords: fighting_game, frame_data, hitbox_hurtbox, input_buffer, motion_inputs, combo_system, rollback_netcode, cancel_system, advantage_frames."
---

# Genre: Fighting Game

Expert blueprint for 2D/3D fighters emphasizing frame-perfect combat and competitive balance.

## NEVER Do (Expert Anti-Patterns)

### Frame-Data & Logic
- NEVER use variable framerates; strictly lock logic to a **Deterministic Fixed Loop** (using `_physics_process` with a frame-counter) and call **`reset_physics_interpolation()`** on teleport.
- NEVER use standard Physics for hit detection; strictly use **`PhysicsDirectSpaceState.intersect_shape()`** to query hitboxes instantly without Area2D signal lag.
- NEVER skip **Damage Scaling**; strictly apply 10% reduction per hit in a combo to prevent infinite matches.
- NEVER make all moves safe on block; strictly ensure high-reward moves have **Recovery Windows** where the attacker is punishable.
- NEVER rely on `Area2D.get_overlapping_areas()`; strictly use **`intersect_shape()`** for immediate, frame-perfect resolution.
- NEVER forget **Hitbox Proximity (Proximity Guard)**; strictly trigger guard states when a hitbox enters a nearby zone, even if it hasn't landed.

### Character & Animation
- NEVER use simple parenting (`scale.x = -1`) for character flip; strictly adjust the dedicated **Visuals node** while managing hitbox offsets programmatically.
- NEVER use string-based animation triggers; strictly use `AnimationMixer` with `ADVANCE_MANUAL` for frame-synced playback.
- NEVER use `yield` or `await` for frame-critical logic; strictly use **Integer Frame Counting** within state machines to manage recovery/startup windows perfectly.
- NEVER store frame data in raw scripts; strictly use **`Resource` files (.tres)** with delegated logic for damage scaling, cancels, and combo-state tracking.
- NEVER use deep node hierarchies for character parts; strictly keep skeletons shallow to reduce transformation overhead.

### Input & Networking
- NEVER skip **Input Buffering**; strictly implement a 5-10 frame buffer to ensure lenient, responsive execution for the player.
- NEVER leave `Input.use_accumulated_input` enabled; strictly disable it to preserve sub-frame timing for precise combo links.
- NEVER use client-side hit detection for netplay; strictly use **rollback netcode** or server validation to prevent desyncs.
- NEVER use standard TCP for multiplayer; strictly use **UDP/ENet** to avoid head-of-line blocking during latency spikes.
- NEVER rely on the SceneTree for fighter transforms in netplay; strictly manage positions in a **serializable data buffer**.
---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [fighting_input_buffer.gd](scripts/fighting_input_buffer.gd) - Frame-locked input engine (60fps) with motion command fuzzy matching (QCF/DP).
- [hitbox_component.gd](scripts/hitbox_component.gd) - Professional hitbox/hurtbox utility with layered collision zones (High/Low/Throw).

### Modular Components
- [deterministic_physics_loop.gd](scripts/deterministic_physics_loop.gd) - Custom loop pattern for frame-perfect game state progression.
- [direct_hitbox_query.gd](scripts/direct_hitbox_query.gd) - PhysicsServer shape-casting for immediate collision resolution.
- [hit_stop_controller.gd](scripts/hit_stop_controller.gd) - Dynamic time-scale manipulation for "impact" feel.
- [manual_animation_advancer.gd](scripts/manual_animation_advancer.gd) - Frame-synced animation control via manual delta processing.
- [rollback_state_serializer.gd](scripts/rollback_state_serializer.gd) - Serialization logic for managing discrete game state snapshots.
- [bitwise_state_flags.gd](scripts/bitwise_state_flags.gd) - High-performance bitwise flags for fighter state tracking.
- [input_accumulation_control.gd](scripts/input_accumulation_control.gd) - Toggle for disabling Godot's input accumulation for sub-frame timing.
- [raw_byte_network_sync.gd](scripts/raw_byte_network_sync.gd) - UDP-based state synchronization for netplay efficiency.
- [string_name_optimization.gd](scripts/string_name_optimization.gd) - Pattern for using pointer-level `StringName` comparisons in AI states.
- [round_timer_logic.gd](scripts/round_timer_logic.gd) - Logic for frame-synced match timers and timeout triggers.

---

## Core Loop

`Neutral Game → Confirm Hit → Execute Combo → Advantage State → Repeat`

## Skill Chain

`godot-project-foundations`, `godot-characterbody-2d`, `godot-input-handling`, `animation`, `godot-combat-system`, `godot-state-machine-advanced`, `multiplayer-lobby`

---

## Frame-Based Combat System

Fighting games operate on **frame data** - discrete time units (typically 60fps).

### Frame Data Fundamentals

```gdscript
class_name Attack
extends Resource

@export var name: String
@export var startup_frames: int  # Frames before hitbox becomes active
@export var active_frames: int   # Frames hitbox is active
@export var recovery_frames: int # Frames after hitbox deactivates
@export var on_hit_advantage: int # Frame advantage when attack hits
@export var on_block_advantage: int # Frame advantage when blocked
@export var damage: int
@export var hitstun: int  # Frames opponent is stunned
@export var blockstun: int # Frames opponent is in blockstun

func get_total_frames() -> int:
    return startup_frames + active_frames + recovery_frames

func is_safe_on_block() -> bool:
    return on_block_advantage >= 0
```

### Frame-Accurate Processing

```gdscript
extends Node

var frame_count: int = 0
const FRAME_DURATION := 1.0 / 60.0
var accumulator: float = 0.0

func _process(delta: float) -> void:
    accumulator += delta
    while accumulator >= FRAME_DURATION:
        process_game_frame()
        frame_count += 1
        accumulator -= FRAME_DURATION

func process_game_frame() -> void:
    # All game logic runs here at fixed 60fps
    for fighter in fighters:
        fighter.process_frame()
```

---

## Input System

### Input Buffering

Store inputs and execute when valid:

```gdscript
class_name InputBuffer
extends Node

const BUFFER_FRAMES := 8  # Industry standard: 5-10 frames
var buffer: Array[InputEvent] = []

func add_input(input: InputEvent) -> void:
    buffer.append(input)
    if buffer.size() > BUFFER_FRAMES:
        buffer.pop_front()

func consume_input(action: StringName) -> bool:
    for i in range(buffer.size() - 1, -1, -1):
        if buffer[i].is_action(action):
            buffer.remove_at(i)
            return true
    return false
```

### Motion Input Detection (Quarter Circle, DP, etc.)

```gdscript
class_name MotionDetector
extends Node

const QCF := ["down", "down_forward", "forward"]  # Quarter Circle Forward
const DP := ["forward", "down", "down_forward"]   # Dragon Punch
const MOTION_WINDOW := 15  # Frames to complete motion

var direction_history: Array[String] = []

func add_direction(dir: String) -> void:
    if direction_history.is_empty() or direction_history[-1] != dir:
        direction_history.append(dir)
    # Keep last N directions
    if direction_history.size() > 20:
        direction_history.pop_front()

func check_motion(motion: Array[String]) -> bool:
    if direction_history.size() < motion.size():
        return false
    # Check if motion appears in recent history
    var recent := direction_history.slice(-MOTION_WINDOW)
    return _contains_sequence(recent, motion)

func _contains_sequence(haystack: Array, needle: Array) -> bool:
    var idx := 0
    for dir in haystack:
        if dir == needle[idx]:
            idx += 1
            if idx >= needle.size():
                return true
    return false
```

---

## Hitbox/Hurtbox System

```gdscript
class_name HitboxComponent
extends Area2D

enum BoxType { HITBOX, HURTBOX, THROW, PROJECTILE }

@export var box_type: BoxType
@export var attack_data: Attack
@export var owner_fighter: Fighter

signal hit_confirmed(target: Fighter, attack: Attack)

func _ready() -> void:
    monitoring = (box_type == BoxType.HITBOX or box_type == BoxType.THROW)
    monitorable = (box_type == BoxType.HURTBOX)
    connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
    if area is HitboxComponent:
        var other := area as HitboxComponent
        if other.box_type == BoxType.HURTBOX and other.owner_fighter != owner_fighter:
            hit_confirmed.emit(other.owner_fighter, attack_data)
```

---

## Combo System

### Hit Confirmation and Combo Counter

```gdscript
class_name ComboTracker
extends Node

var combo_count: int = 0
var combo_damage: int = 0
var in_combo: bool = false
var damage_scaling: float = 1.0

const SCALING_PER_HIT := 0.9  # 10% reduction per hit

func start_combo() -> void:
    in_combo = true
    combo_count = 0
    combo_damage = 0
    damage_scaling = 1.0

func add_hit(base_damage: int) -> int:
    combo_count += 1
    var scaled_damage := int(base_damage * damage_scaling)
    combo_damage += scaled_damage
    damage_scaling *= SCALING_PER_HIT
    return scaled_damage

func drop_combo() -> void:
    in_combo = false
    combo_count = 0
    damage_scaling = 1.0
```

### Cancel System

```gdscript
enum CancelType { NONE, NORMAL, SPECIAL, SUPER }

func can_cancel_into(from_attack: Attack, to_attack: Attack) -> bool:
    # Normal → Special → Super hierarchy
    match to_attack.cancel_type:
        CancelType.NORMAL:
            return from_attack.cancel_type == CancelType.NONE
        CancelType.SPECIAL:
            return from_attack.cancel_type in [CancelType.NONE, CancelType.NORMAL]
        CancelType.SUPER:
            return true  # Supers can cancel anything
    return false
```

---

## Character States

```gdscript
enum FighterState {
    IDLE, WALKING, CROUCHING, JUMPING,
    ATTACKING, BLOCKING, HITSTUN, BLOCKSTUN,
    KNOCKDOWN, WAKEUP, THROW, THROWN
}

class_name FighterStateMachine
extends Node

var current_state: FighterState = FighterState.IDLE
var state_frame: int = 0

func transition_to(new_state: FighterState) -> void:
    exit_state(current_state)
    current_state = new_state
    state_frame = 0
    enter_state(new_state)

func is_actionable() -> bool:
    return current_state in [
        FighterState.IDLE,
        FighterState.WALKING,
        FighterState.CROUCHING
    ]
```

---

## Netcode Considerations

### Rollback Essentials

```gdscript
class_name GameState
extends Resource

# Serialize complete game state for rollback
func save_state() -> Dictionary:
    return {
        "frame": frame_count,
        "fighters": fighters.map(func(f): return f.serialize()),
        "projectiles": projectiles.map(func(p): return p.serialize())
    }

func load_state(state: Dictionary) -> void:
    frame_count = state["frame"]
    for i in fighters.size():
        fighters[i].deserialize(state["fighters"][i])
    # Reconstruct projectiles...
```

---

## Balance Guidelines

| Element | Guideline |
|---------|-----------|
| Health | 10,000-15,000 for ~20 second rounds |
| Combo damage | Max 30-40% of health per touch |
| Fastest moves | 3-5 frames startup (jabs) |
| Slowest moves | 20-40 frames (supers, overheads) |
| Throw range | Short but reliable |
| Meter gain | Full bar in ~2 combos received |

---

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Infinite combos | Implement hitstun decay and gravity scaling |
| Unblockable setups | Ensure all attacks have counterplay |
| Lag input drops | Robust input buffering (8+ frames) |
| Desync in netplay | Deterministic physics, rollback netcode |

---

## Godot-Specific Tips

1. **Use `_physics_process` sparingly** - implement your own frame-based loop
2. **AnimationPlayer**: Tie hitbox activation to animation frames
3. **Custom collision**: May need custom hitbox system rather than physics engine
4. **Save/Load for rollback**: Keep state serializable


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
