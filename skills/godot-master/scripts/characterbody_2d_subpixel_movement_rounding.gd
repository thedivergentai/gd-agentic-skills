# subpixel_movement_rounding.gd
# Ensuring clean visuals at low resolutions [Pixel Art]
extends CharacterBody2D

# EXPERT NOTE: Physics usually uses floats. Pixel art needs integers.
# Rounding global_position directly causes jitter.
# SOLUTION: Keep physics high-precision, but round the Sprite's position.

func _process(_delta: float) -> void:
	var sprite = $Sprite2D
	# Round to nearest pixel for display only
	sprite.global_position = global_position.round()
