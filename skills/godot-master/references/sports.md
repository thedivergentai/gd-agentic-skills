> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Sports**. Accessed via Godot Master.

# Genre: Sports

Expert blueprint for building team-based and arcade sports games. Focuses on physical ball dynamics (Magnus Effect, Drag), formation-based team AI, and contextual input management.

## Available Scripts

### [sports_ball_physics.gd](../scripts/sports_sports_ball_physics.gd)
A high-fidelity physics model for ball-centric sports. Implements realistic air drag, bounce friction, and the **Magnus Effect** (allowing for curved shots/swerves) through `_integrate_forces`.

### [team_manager.gd](../scripts/sports_team_manager.gd)
Manages the macro-behavior of a sports team. Implements "Formation Slots" to prevent the "Kindergarten Soccer" problem where every NPC chases the ball. Regulates team strategies (Attack vs. Defense) and player-switching logic.


## NEVER Do

- **NEVER parent the ball directly to the player's Transform** — This creates a "magnetic" or "glued" feel that lacks physicality. Always keep the ball as a standalone `RigidBody3D` and use `apply_central_impulse()` for subtle dribble touches or kicks.
- **NEVER allow all AI players to chase the ball at once** — Known as the "Kindergarten Soccer" problem. Implement **Formation Slots** (Defense, Midfield, Attack); only the closest 1-2 players should engage the ball, while others maintain their relative positions in the formation.
- **NEVER use instant, perfect goalkeeper reflexes** — In arcade sports, a keeper that saves everything is frustrating. Always add a **Reaction Delay** (0.2s - 0.5s) and an "Error Rate" based on the speed and angle of the incoming shot.
- **NEVER use a single collision shape for the player body** — To handle realistic ball interaction (headers, chest traps, and foot shots), use separate collision shapes/layers for the Head, Torso, and Legs.
- **NEVER allow the ball to "Tunnel" through goals** — Fast-moving balls can skip over collision checks. ALWAYS enable `continuous_cd = true` (Continuous Collision Detection) on the ball's `RigidBody3D` properties.
- **NEVER skip Root Motion for player movement** — Sudden turns and stops in sports must have realistic momentum. Using simple `position` lerping looks unnatural. Use `AnimationTree` with **Root Motion** to derive movement from the animations themselves.

---

## Physics: The Magnus Effect
To allow the ball to "Curve" or "Swerve" in the air, apply a force perpendicular to both the velocity and the spin:
```gdscript
var magnus_force = angular_velocity.cross(linear_velocity) * strength
apply_central_force(magnus_force)
```
This is essential for soccer (bending shots), baseball (curveballs), and tennis.

## Contextual Input System
In sports games, one button typically performs different actions based on proximity to the ball:
- **Button A (Possession)**: Pass.
- **Button A (No Possession)**: Switch Player.
- **Button A (Near Opponent)**: Slide Tackle.
Use a `ContextManager` to determine which action is valid before executing the input.

## Advanced Team AI: Formations
- **The Formation Anchor**: A node that lerps toward the ball's position on the field.
- **Slot Markers**: Child nodes of the Anchor defining the ideal position for each role (Back, Left Wing, Striker, etc.).
- **Assignment**: Every few seconds, calculate the closest player to each slot and issue a `seek` command.

## Broadcast Camera Logic
Use a `Camera3D` with a high FOV that follows the "Center of Mass" between the ball and the primary player.
- **Zooming**: Zoom in when the ball enters the "Goal Zone."
- **Smoothing**: Use `SpringArm3D` or a lerped follow to prevent jerky movements during high-speed transitions.

## Reference
- [Godot Docs: Using RigidBody3D](https://docs.godotengine.org/en/stable/tutorials/physics/using_rigidbody_3d.html)
- [GDC: The Physics of Rocket League](https://www.youtube.com/watch?v=ueEmiDM94IE)
