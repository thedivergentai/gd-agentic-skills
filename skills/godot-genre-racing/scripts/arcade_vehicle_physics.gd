# skills/genre-racing/scripts/arcade_vehicle_physics.gd
extends VehicleBody3D

## Arcade Vehicle Physics (Expert Pattern)
## Custom tweaks for VehicleBody3D to make it feel "fun" rather than realistic.
## Increases gravity, modifies friction for drifting, and handles air control.

class_name ArcadeVehiclePhysics

@export var gravity_scale: float = 3.0 # Arcade cars need to stick to the ground
@export var air_control: float = 0.5
@export var drift_friction_slip: float = 1.0
@export var normal_friction_slip: float = 3.0

var is_drifting: bool = false

func _ready() -> void:
    # Setup wheels
    for child in get_children():
        if child is VehicleWheel3D:
             child.wheel_friction_slip = normal_friction_slip

func _physics_process(delta: float) -> void:
    # 1. Custom Gravity
    if not is_on_floor():
        apply_central_force(Vector3.DOWN * 9.8 * gravity_scale * mass)
        
        # 2. Air Control (Tilt)
        var pitch = Input.get_axis("forward", "back") * air_control
        var roll = Input.get_axis("left", "right") * air_control
        apply_torque(transform.basis.x * pitch + transform.basis.z * roll)
        
    # 3. Drifting Logic
    if Input.is_action_pressed("drift"):
        is_drifting = true
        for child in get_children():
            if child is VehicleWheel3D and not child.use_as_steering: # Rear wheels usually
                child.wheel_friction_slip = drift_friction_slip
    else:
        is_drifting = false
        for child in get_children():
            if child is VehicleWheel3D:
                child.wheel_friction_slip = normal_friction_slip

func is_on_floor() -> bool:
    # Simple raycast check or wheel contact check
    for child in get_children():
        if child is VehicleWheel3D and child.is_colliding():
            return true
    return false

## EXPERT USAGE:
## Attach to VehicleBody3D. Map 'drift', 'forward', 'back', 'left', 'right' actions.
