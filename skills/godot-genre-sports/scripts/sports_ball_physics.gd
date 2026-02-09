# skills/genre-sports/scripts/sports_ball_physics.gd
extends RigidBody3D

## Sports Ball Physics (Expert Pattern)
## Implements Magnus Effect (curve) and air drag for realistic ball flight.

class_name SportsBallPhysics

@export var drag_coefficient: float = 0.01
@export var magnus_strength: float = 0.5
@export var air_density: float = 1.2

func _ready() -> void:
    # Ensure continuous collision detection for fast balls
    custom_integrator = true
    continuous_cd = true
    contact_monitor = true
    max_contacts_reported = 3

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    var velocity = state.linear_velocity
    var speed = velocity.length()
    
    if speed < 0.1: return
    
    # Drag Force: Fd = -0.5 * p * v^2 * Cd * A (simplified)
    # Direction opposite to velocity
    var drag_force = -velocity.normalized() * (0.5 * air_density * speed * speed * drag_coefficient)
    state.apply_central_force(drag_force)
    
    # Magnus Effect: Fm = S(w x v)
    # Cross product of angular velocity and linear velocity
    var angular_vel = state.angular_velocity
    if angular_vel.length_squared() > 1.0:
        var magnus_force = angular_vel.cross(velocity) * magnus_strength
        state.apply_central_force(magnus_force)

## EXPERT USAGE:
## Attach to a RigidBody3D. Set Linear/Angular Damp to 0 in inspector 
## (since we apply custom drag). Shoot ball with 'apply_impulse'.
