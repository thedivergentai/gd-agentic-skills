# arcade_vehicle_controller.gd
extends CharacterBody3D
class_name ArcadeVehicleController

# Raycast-Based Arcade Vehicle Controller
# Predictable, tight steering and suspension without the complexity of VehicleBody3D.

@export var engine_force := 40.0
@export var steering_limit := 0.4
@export var suspension_rest_dist := 0.5
@export var suspension_stiffness := 30.0
@export var suspension_damping := 2.0

func _physics_process(delta: float) -> void:
    var input_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
    
    # Steering
    rotation.y -= input_dir.x * steering_limit * delta * (velocity.length() * 0.1)
    
    # Simple Engine Acceleration
    var forward_dir = -global_transform.basis.z
    velocity += forward_dir * input_dir.y * engine_force * delta
    
    # Friction/Drag
    velocity *= 0.98
    
    move_and_slide()
