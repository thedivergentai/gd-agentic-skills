class_name EasterWobblePhysicsBody
extends RigidBody3D

## Expert wobbly physics for 'Egg-like' interaction.
## Applies a random offset to the center of mass to create organic instability.

func _ready() -> void:
	# Shift center of mass slightly to cause a wobble when it rolls
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(randf_range(-0.1, 0.1), -0.2, randf_range(-0.1, 0.1))

## Tip: Low friction + Custom Center of Mass = High quality organic egg motion.
