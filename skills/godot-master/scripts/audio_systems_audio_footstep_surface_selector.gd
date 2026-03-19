class_name AudioFootstepSurfaceSelector
extends RayCast3D

## Expert multi-surface footstep selector.
## Detects floor type via Physics and picks the correct sound bank.

var surface_sounds: Dictionary = {
	"Stone": preload("res://audio/steps_stone.tres"),
	"Wood": preload("res://audio/steps_wood.tres")
}

func get_step_stream() -> AudioStream:
	if is_colliding():
		var collider = get_collider()
		# Expert: Use Groups or Metadata to identify surface type
		for group in surface_sounds.keys():
			if collider.is_in_group(group):
				return surface_sounds[group].get_random()
	return null
