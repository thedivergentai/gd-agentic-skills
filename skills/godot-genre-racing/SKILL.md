---
name: godot-genre-racing
description: "Expert blueprint for racing games including vehicle physics (VehicleBody3D, suspension, friction), checkpoint systems (prevent shortcuts), rubber-banding AI (keep races competitive), drifting mechanics (reduce friction, boost on exit), camera feel (FOV increase with speed, motion blur), and UI (speedometer, lap timer, minimap). Use for arcade racers, kart racing, or realistic sims. Trigger keywords: racing_game, vehicle_physics, checkpoint_system, rubber_banding, drifting_mechanics, camera_feel."
---

# Genre: Racing

Expert blueprint for racing games balancing physics, competition, and sense of speed.

## NEVER Do (Expert Anti-Patterns)

### Physics & Handling
- NEVER use a rigid camera attachment; strictly use a **Smooth Follow** pattern with `lerp()` to prevent motion sickness.
- NEVER prioritize realism over fun; strictly increase **Gravity Scale** (2x-3x) and keep friction high for responsive arcade feel.
- NEVER use `VehicleBody3D` default settings for karts; strictly rewrite suspension using Raycasts or custom spring/damper models.
- NEVER apply steering torque directly to mass; strictly use a steering curve factored by lateral velocity.
- NEVER calculate suspension without a damper model; strictly include damping to prevent eternal oscillation (bouncing).
- NEVER ignore the **Center of Mass** property; strictly offset it downward to ensure stability during high-speed turns.
- NEVER multiply engine force by `delta`; it is an integrated force in the physics solver.
- NEVER rely on `is_action_pressed()` for manual gear shifting; strictly use `is_action_just_pressed()` for single-tap accuracy.

### AI & Competition
- NEVER use static AI speeds; strictly use **Rubber-Banding** to keep races competitive based on player distance.
- NEVER run AI pathfinding across the entire track every frame; strictly use a "Look-Ahead" point on a spline/path.
- NEVER ignore racing **Checkpoints**; strictly enforce sequential `Area3D` validation to prevent track shortcuts.
- NEVER use standard `Area3D` for slipstreaming without a **Dot Product** check to ensure the player is directly behind.

### Visuals & Audio
- NEVER skip "Sense of Speed" effects; strictly implement dynamic **FOV scaling**, motion blur, and high-speed camera shake.
- NEVER update minimap transforms for static elements in `_process()`; strictly update dynamic racers only.
- NEVER serialize ghost cars as mass transform lists; strictly store positions/quaternions at fixed intervals.
- NEVER use constant pitch for engine sounds; strictly map RPM or engine load to `pitch_scale`.
- NEVER spawn particles for skid marks every frame; strictly use **Trail3D** or procedural strips for low-cost persistence.
- NEVER use standard Strings for surface detection; strictly use `StringName` (e.g., `&"asphalt"`).

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [arcade_vehicle_physics.gd](scripts/arcade_vehicle_physics.gd) - High-performance arcade handling with custom gravity, air control, and friction-slip drifting.
- [spline_ai_controller.gd](scripts/spline_ai_controller.gd) - Professional racing AI using Path3D predictive steering and rubber-banding logic.

### Modular Components
- [arcade_vehicle_controller.gd](scripts/arcade_vehicle_controller.gd) - Alternative tight, raycast-based vehicle movement model for non-physics karts.
- [slipstream_handler.gd](scripts/slipstream_handler.gd) - Drafting zones with relative dot-product checks for speed boosts.
- [lap_tracker.gd](scripts/lap_tracker.gd) - High-precision lap management with sequential checkpoint logic.
- [ghost_recorder.gd](scripts/ghost_recorder.gd) - Binary transform serialization for lightweight ghost car playback.
- [engine_audio_controller.gd](scripts/engine_audio_controller.gd) - RPM-to-pitch audio synthesis for engine revving and gear shifts.
- [skid_mark_emitter.gd](scripts/skid_mark_emitter.gd) - Conditional tire-slip trail system for persistent visual feedback.
- [minimap_icon_projector.gd](scripts/minimap_icon_projector.gd) - 3D-to-2D bridge for projecting racers onto a localized UI.
- [force_feedback_router.gd](scripts/force_feedback_router.gd) - Haptic and rumble management based on terrain and collisions.
- [raycast_suspension.gd](scripts/raycast_suspension.gd) - Spring/damper model for raycast wheels with configurable stiffness.
- [racing_checkpoint.gd](scripts/racing_checkpoint.gd) - Indexed trigger gate for modular track-based lap progression.

---

## Core Loop
1.  **Race**: Player controls a vehicle on a track.
2.  **Compete**: Player overtakes opponents or beats the clock.
3.  **Upgrade**: Player earns currency/points to buy parts/cars.
4.  **Tune**: Player adjusts vehicle stats (grip, acceleration).
5.  **Master**: Player learns track layouts and optimal lines.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Physics | `physics-bodies`, `vehicle-wheel-3d` | Car movement, suspension, collisions |
| 2. AI | `navigation`, `steering-behaviors` | Opponent pathfinding, rubber-banding |
| 3. Input | `input-mapping` | Analog steering, acceleration, braking |
| 4. UI | `progress-bars`, `labels` | Speedometer, lap timer, minimap |
| 5. Feel | `camera-shake`, `godot-particles` | Speed perception, tire smoke, sparks |

## Architecture Overview

### 1. Vehicle Controller
Handling the physics of movement.

```gdscript
# car_controller.gd
extends VehicleBody3D

@export var max_torque: float = 300.0
@export var max_steering: float = 0.4

func _physics_process(delta: float) -> void:
    steering = lerp(steering, Input.get_axis("right", "left") * max_steering, 5 * delta)
    engine_force = Input.get_axis("back", "forward") * max_torque
```

### 2. Checkpoint System
Essential for tracking progress and preventing cheating.

```gdscript
# checkpoint_manager.gd
extends Node

var checkpoints: Array[Area3D] = []
var current_checkpoint_index: int = 0
signal lap_completed

func _on_checkpoint_entered(body: Node3D, index: int) -> void:
    if index == current_checkpoint_index + 1:
        current_checkpoint_index = index
    elif index == 0 and current_checkpoint_index == checkpoints.size() - 1:
        complete_lap()
```

### 3. Race Manager
high-level state machine.

```gdscript
# race_manager.gd
enum State { COUNTDOWN, RACING, FINISHED }
var current_state: State = State.COUNTDOWN

func start_race() -> void:
    # 3.. 2.. 1.. GO!
    await countdown()
    current_state = State.RACING
    start_timer()
```

## Key Mechanics Implementation

### Drifting
Arcade drifting usually involves faking physics. Reduce friction or apply a sideways force.

```gdscript
func apply_drift_mechanic() -> void:
    if is_drifting:
        # Reduce sideways traction
        wheel_friction_slip = 1.0 
        # Add slight forward boost on exit
    else:
        wheel_friction_slip = 3.0 # High grip
```

### Rubber Banding AI
Keep the race competitive by adjusting AI speed based on player distance.

```gdscript
func update_ai_speed(ai_car: VehicleBody3D, player: VehicleBody3D) -> void:
    var dist = ai_car.global_position.distance_to(player.global_position)
    if ai_car_is_ahead_of_player(ai_car, player):
        ai_car.max_speed = base_speed * 0.9 # Slow down
    else:
        ai_car.max_speed = base_speed * 1.1 # Speed up
```

## Godot-Specific Tips

*   **VehicleBody3D**: Godot's built-in node for vehicle physics. It's decent for arcade, but for sims, you might want a custom RayCast suspension.
*   **Path3D / PathFollow3D**: Excellent for simple AI traffic or fixed-path racers (on-rails).
*   **AudioBus**: Use the `Doppler` effect on the AudioListener for realistic passing sounds.
*   **SubViewport**: Use for the rear-view mirror or minimap texture.

## Common Pitfalls

1.  **Floaty Physics**: Cars feel like they are on ice. **Fix**: Increase gravity scale (2x-3x) and adjust wheel friction. Realism < Fun.
2.  **Bad Camera**: Camera is rigidly attached to the car. **Fix**: Use a `Marker3D` with a `lerp` script to follow the car smoothly with a slight delay.
3.  **Tunnel Vision**: No sense of speed. **Fix**: Increase FOV as speed increases, add camera shake, wind lines, and motion blur.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
