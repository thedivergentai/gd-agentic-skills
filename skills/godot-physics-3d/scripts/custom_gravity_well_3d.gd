# custom_gravity_well_3d.gd
# 3D Gravity wells and directional overrides via Area3D
extends Area3D

func _ready() -> void:
	# Replace world gravity with point force
	gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
	gravity_point = true
	gravity_point_unit_distance = 10.0
	gravity = 20.0 # Force attraction
	
	# For planetary gravity (spherical):
	# gravity_direction = Vector3.ZERO # Point toward center
