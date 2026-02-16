# godot-master/scripts/2d_physics_custom_physics.gd
extends RigidBody2D

## Deterministic Solver & Custom Gravity Pattern
## Demonstrates _integrate_forces for absolute control over physics state.

@export var custom_gravity_scale := 1.0
@export var local_gravity_center: Node2D

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    # --- 1. Custom Movement Math ---
    # Override velocity directly while remaining in the physics solver
    # This prevents 'jitter' compared to manual position changes
    
    var current_vel := state.linear_velocity
    # Apply custom dampening or acceleration
    # current_vel.x = move_toward(current_vel.x, target_speed, accel * state.step)
    
    # --- 2. Localized Gravity Fields ---
    if local_gravity_center:
        var dir := global_position.direction_to(local_gravity_center.global_position)
        var force := dir * 9.8 * custom_gravity_scale
        state.apply_central_force(force)
        
    # --- 3. Deterministic Stop ---
    if should_stop_instantly():
        state.linear_velocity = Vector2.ZERO
        state.angular_velocity = 0

func should_stop_instantly() -> bool:
    return false

## EXPERT NOTE:
## Always use 'state.step' for delta-consistency in _integrate_forces.
## This function is called during the physics synchronization phase, 
## making it the correct place for custom physics engines or character controllers
## that require RigidBody interactions without the 'floatiness' of default physics.
