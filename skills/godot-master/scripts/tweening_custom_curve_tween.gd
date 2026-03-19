# custom_curve_tween.gd
# Driving property animations using visual Curve resources
extends Node2D

@export var bounce_curve: Curve

# EXPERT NOTE: For juice, avoid standard TransTypes and use a 
# Curve resource for total control over the easing profile.

func juice_impact():
	var tween = create_tween()
	# The scale will follow the visual curve exactly
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.6)\
		.set_custom_interpolator(func(v): return bounce_curve.sample(v))
	
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.2)
