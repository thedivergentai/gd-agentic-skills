# Expert Environment Sky and Fog Blender
extends WorldEnvironment

## Smoothly transition environments (Sky exposure, Fog density) 
## for indoor-to-outdoor transitions using Tweens.

func transition_to_outdoor(duration: float = 2.0) -> void:
	var tween = create_tween().set_parallel(true)
	
	# Adjust sky contribution for global lighting
	tween.tween_property(environment, "ambient_light_sky_contribution", 1.0, duration)
	
	# Reveal distant volumetric fog
	tween.tween_property(environment, "volumetric_fog_density", 0.01, duration)
	
	# Sun/exposure adjustments
	tween.tween_property(environment, "tonemap_exposure", 1.0, duration)

func transition_to_indoor(duration: float = 2.0) -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(environment, "ambient_light_sky_contribution", 0.1, duration)
	tween.tween_property(environment, "volumetric_fog_density", 0.05, duration)
	tween.tween_property(environment, "tonemap_exposure", 0.6, duration)
