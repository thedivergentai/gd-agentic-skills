# vehicle_simulation_tuning.gd
# Tuning VehicleBody3D for arcade-style high-speed racing
extends VehicleBody3D

# EXPERT NOTE: VehicleBody3D is a complex Raycast-based sim. 
# Tuning 'Stiffness' and 'Friction' on VehicleWheel3D is 
# more important than engine force for 'feel'.

func apply_drift_physics(active: bool):
	for wheel in get_children():
		if wheel is VehicleWheel3D:
			# Lower friction for drifting
			wheel.wheel_friction_slip = 0.5 if active else 1.0
			# Aggressive steering response
			wheel.steering = Input.get_axis("right", "left") * 0.4
