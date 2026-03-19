# custom_gravity_area.gd
# Implementing custom gravity wells and directional zones
extends Area2D

# Expert: Using Area2D 'Priority' and 'Gravity' overrides.

func _ready() -> void:
	# High priority ensures this gravity overrides the global world gravity
	gravity_space_override = Area2D.SPACE_OVERRIDE_REPLACE
	gravity_point = true
	gravity_point_unit_distance = 100.0
	gravity = 980.0 # Attraction force
	
	# For directional gravity (e.g. anti-gravity lift)
	# gravity_space_override = Area2D.SPACE_OVERRIDE_REPLACE
	# gravity_direction = Vector2.UP
