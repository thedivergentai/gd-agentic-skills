# godot-master/scripts/racing_spline_ai_controller.gd
extends VehicleBody3D

## Spline AI Controller (Expert Pattern)
## Racing AI that follows a Path3D with look-ahead steering and rubber-banding.

class_name SplineAIController

@export var path: Path3D
@export var max_speed: float = 50.0 # m/s
@export var rubber_band_strength: float = 0.1
@export var target_node: Node3D # The player (for rubber banding)

var current_offset: float = 0.0
var look_ahead: float = 20.0

func _physics_process(delta: float) -> void:
    if not path: return
    
    # 1. Find Closest Point on Curve
    var curve = path.curve
    # Approximating offset update based on speed (better than searching nearest every frame)
    current_offset += linear_velocity.length() * delta
    if current_offset >= curve.get_baked_length():
        current_offset -= curve.get_baked_length() # Loop
        
    # 2. Calculate Steering Target (Look Ahead)
    var target_offset = current_offset + look_ahead
    if target_offset >= curve.get_baked_length():
        target_offset -= curve.get_baked_length()
        
    var target_pos = path.to_global(curve.sample_baked(target_offset))
    var local_target = to_local(target_pos)
    
    # 3. Apply Steering
    # Simple P-controller: steer towards x component of local target
    steering = clamp(local_target.x * 0.1, -0.4, 0.4)
    
    # 4. Apply Throttle / Rubber Banding
    var desired_speed = max_speed
    if target_node:
        var dist = global_position.distance_to(target_node.global_position)
        # If behind, speed up
        # We need to know track position to know who is ahead, simple distance check is flawed on loops
        # Assuming linear track progress for simple rubber band example:
        if current_offset < _get_node_track_offset(target_node): 
            desired_speed *= (1.0 + rubber_band_strength)
        else:
            desired_speed *= (1.0 - rubber_band_strength)
            
    if linear_velocity.length() < desired_speed:
        engine_force = 1000.0
        brake = 0.0
    else:
        engine_force = 0.0
        brake = 10.0

func _get_node_track_offset(node: Node3D) -> float:
    # Helper to find approx offset of player
    return path.curve.get_closest_offset(path.to_local(node.global_position))

## EXPERT USAGE:
## Assign a Path3D (the racing line). Adjust look_ahead for smoother turns.
