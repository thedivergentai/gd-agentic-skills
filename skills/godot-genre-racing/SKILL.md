---
name: godot-genre-racing
description: "Expert blueprint for racing games including vehicle physics (VehicleBody3D, suspension, friction), checkpoint systems (prevent shortcuts), rubber-banding AI (keep races competitive), drifting mechanics (reduce friction, boost on exit), camera feel (FOV increase with speed, motion blur), and UI (speedometer, lap timer, minimap). Use for arcade racers, kart racing, or realistic sims. Trigger keywords: racing_game, vehicle_physics, checkpoint_system, rubber_banding, drifting_mechanics, camera_feel."
---

# Genre: Racing

Expert blueprint for racing games balancing physics, competition, and sense of speed.

## NEVER Do

- **NEVER rigid camera attachment** — Camera locked to car causes motion sickness. Use lerp with slight delay for smooth follow.
- **NEVER skip sense of speed** — Increase FOV as speed increases, add camera shake, wind lines, motion blur. Tunnel vision breaks immersion.
- **NEVER make physics overly realistic** — "Floaty" arcade feel is often more fun than simulation. Increase gravity 2-3x, adjust wheel friction.
- **NEVER forget checkpoints** — Without validation, players exploit shortcuts. Enforce checkpoint sequence to complete laps.
- **NEVER ignore rubber-banding** — AI that's too far ahead/behind makes races boring. Adjust AI speed dynamically based on player distance.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [spline_ai_controller.gd](scripts/spline_ai_controller.gd)
Path3D-based racing AI. Projects position onto curve, calculates look-ahead for steering, applies throttle based on target speed vs velocity.

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
