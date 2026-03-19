# continuous_collision_detection.gd
# Managing CCD for high-speed projectiles to prevent tunneling
extends RigidBody2D

# PROBLEM: High-speed bullets can skip through thin walls between frames.
# SOLUTION: Enable Continuous Collision Detection (CCD).

func _ready() -> void:
	# CCD_MODE_CAST_RAY is usually enough for most projectiles
	# CCD_MODE_CAST_SHAPE is the most accurate but expensive
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	
	# Optimization: Only use CCD for high-speed phases
	contact_monitor = true
	max_contacts_reported = 1
