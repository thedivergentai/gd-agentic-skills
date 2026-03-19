# joint_3d_breakage_logic.gd
# Dynamic PinJoint3D/HingeJoint3D breakage under stress
extends Generic6DOFJoint3D

@export var break_force: float = 1000.0

func _physics_process(_delta: float) -> void:
	# Check impulse applied to the joint
	# Note: In Godot 4, finding the exact joint stress 
	# usually requires checking velocity deltas of the two bodies.
	var body_a = get_node(node_a) as RigidBody3D
	var body_b = get_node(node_b) as RigidBody3D
	
	if body_a and body_b:
		var stress = (body_a.linear_velocity - body_b.linear_velocity).length()
		if stress > break_force:
			queue_free() # Snap the joint
