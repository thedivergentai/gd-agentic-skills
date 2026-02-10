---
name: godot-genre-sports
description: "Expert blueprint for sports games (FIFA, NBA 2K, Rocket League, Tony Hawk) covering physics-based ball interaction, team AI formations, contextual input, and broadcast camera systems. Use when building soccer, basketball, hockey, racing sports, or arcade sports games. Keywords ball physics, magnus effect, formation AI, team tactics, contextual controls, steering behaviors."
---

# Genre: Sports

## Available Scripts

### [sports_ball_physics.gd](scripts/sports_ball_physics.gd)
Expert ball physics with drag, magnus effect (curve), and proper bounce handling.

## Core Loop
1.  **Possession**: Player or AI controls the ball/puck
2.  **Maneuver**: Player avoids opponents (dribble, pass)
3.  **Strike**: Player attempts to score (shoot, dunk)
4.  **Defend**: Opposing team tries to steal or block
5.  **Score**: Points determine winner after time

## NEVER Do in Sports Games

- **NEVER parent ball to player transform** — Ball must be physics-based, not child node. Parenting = magnetic stick feel, unrealistic. Use `apply_central_impulse()` for dribble touches.
- **NEVER make all AI chase the ball** — Kindergarten soccer problem. Use formation slots: only 1-2 players press ball, others cover space/mark opponents.
- **NEVER use perfect instant goalkeeper reflexes** — Add reaction time delay (0.2-0.5s) and error rate based on shot speed. Instant = unfair, frustrating.
- **NEVER ignore animation root motion for player movement** — Sports need realistic momentum/turning. Teleporting to animation end position breaks feel. Use `AnimationTree` root motion.
- **NEVER use single collision shape for player body** — Head, torso, legs need separate hitboxes for realistic ball contact (headers vs foot shots).
- **NEVER allow ball to clip through goalposts** — Use Continuous CD (`continuous_cd`) for fast-moving ball. Standard discrete physics = tunneling at high speeds.

---

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Physics | `physics-bodies`, `vehicle-wheel-3d` | Ball bounce, friction, player collisions |
| 2. AI | `steering-behaviors`, `godot-state-machine-advanced` | Formations, marking, flocking |
| 3. Anim | `godot-animation-tree-mastery` | Blended running, shooting, tackling |
| 4. Input | `input-mapping` | Contextual buttons (Pass/Tackle share button) |
| 5. Camera | `godot-camera-systems` | Dynamic broadcast view, zooming on action |

## Architecture Overview

### 1. The Ball (Physics Core)
The most important object. Must feel right.

```gdscript
# ball.gd
extends RigidBody3D

@export var drag_coefficient: float = 0.5
@export var magnus_effect_strength: float = 2.0

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    # Apply Air Drag
    var velocity = state.linear_velocity
    var speed = velocity.length()
    var drag_force = -velocity.normalized() * (drag_coefficient * speed * speed)
    state.apply_central_force(drag_force)
    
    # Magnus Effect (Curve)
    var spin = state.angular_velocity
    var magnus_force = spin.cross(velocity) * magnus_effect_strength
    state.apply_central_force(magnus_force)
```

### 2. Team AI (Formations)
AI players don't just run at the ball. They run to *positions* relative to the ball/field.

```gdscript
# team_manager.gd
extends Node

enum Strategy { ATTACK, DEFEND }
var current_strategy: Strategy = Strategy.DEFEND
var formation_slots: Array[Node3D] # Markers parented to a "Formation Anchor"

func update_tactics(ball_pos: Vector3) -> void:
    # Move the entire formation anchor
    formation_anchor.position = lerp(formation_anchor.position, ball_pos, 0.5)
    
    # Assign best player to each slot
    for player in players:
        var best_slot = find_closest_slot(player)
        player.set_target(best_slot.global_position)
```

### 3. Match Manager
The referee logic.

```gdscript
# match_manager.gd
var score_team_a: int = 0
var score_team_b: int = 0
var match_timer: float = 300.0
enum State { KICKOFF, PLAYING, GOAL, END }

func goal_scored(team: int) -> void:
    if team == 0: score_team_a += 1
    else: score_team_b += 1
    current_state = State.GOAL
    play_celebration()
    await get_tree().create_timer(5.0).timeout
    reset_positions()
    current_state = State.KICKOFF
```

## Key Mechanics Implementation

### Contextual Input
"A" button does different things depending on context.

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("action_main"):
        if has_ball:
            pass_ball()
        elif is_near_ball:
            slide_tackle()
        else:
            switch_player()
```

### Steering Behaviors
For natural movement (Seek, Flee, Arrive).

```gdscript
func seek(target_pos: Vector3) -> Vector3:
    var desired_velocity = (target_pos - global_position).normalized() * max_speed
    var steering = desired_velocity - velocity
    return steering.limit_length(max_force)
```

## Godot-Specific Tips

*   **NavigationServer3D**: Essential for avoiding obstacles (other players/referee).
*   **AnimationTree (BlendSpace2D)**: Crucial for sports. You need smooth blending between Idle -> Walk -> Jog -> Sprint in all directions.
*   **PhysicsMaterial**: Tune `bounce` and `friction` on the Ball and Field colliders carefully.

## Common Pitfalls

1.  **AI Bunching**: All 22 players running at the ball (Kindergarten Soccer). **Fix**: Use Formation Slots. Only 1-2 players "Press" the ball; others cover space.
2.  **Magnetic Ball**: Ball sticks to player too perfectly. **Fix**: Use a "Dribble" mechanic where the player kicks the ball slightly ahead physics-wise, rather than parenting it.
3.  **Unfair Goalies**: Goalie reacts instantly. **Fix**: Add a "Reaction Time" delay and "Error Rate" based on shot speed/stats.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
