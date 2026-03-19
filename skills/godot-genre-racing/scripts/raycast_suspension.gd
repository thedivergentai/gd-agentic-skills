# raycast_suspension.gd
extends RayCast3D
class_name RaycastSuspension

# Physics-Based Suspension (Raycast Spring)
# Calculates upward force based on compression to simulate vehicle bounce.

@export var stiffness := 40.0
@export var damping := 3.0
var last_compression := 0.0

func get_spring_force(delta: float) -> float:
    if is_colliding():
        var contact_dist = (get_collision_point() - global_position).length()
        var compression = clamp(target_position.length() - contact_dist, 0.0, 1.0)
        
        # Spring force
        var force = compression * stiffness
        # Damping (velocity of compression)
        var vel = (compression - last_compression) / delta
        force += vel * damping
        
        last_compression = compression
        return force
    
    last_compression = 0.0
    return 0.0
