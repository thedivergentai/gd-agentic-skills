# physics_ccd_3d_projectile.gd
# Managing CCD and physics steps for high-speed 3D objects
extends RigidBody3D

# PROBLEM: Sniper bullets can skip through 1m thick walls at 300m/s.
# SOLUTION: Enable CCD and use sub-stepping or a custom integration.

func _ready() -> void:
	# CCD_MODE_CAST_RAY is the standard for bullets
	continuous_cd = true # In 4.0+, this is a boolean or enum depending on version
	# Note: In Godot 4, CCD is configured via individual body settings or Server.
	
	# Optimization: Report only the first contact
	max_contacts_reported = 1
	contact_monitor = true
