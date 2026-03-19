# ReflectionProbe Dynamic Bake Manager
extends ReflectionProbe

## Real-time reflections tank performance. 
## Expert pattern: Trigger an UPDATE_ONCE only when large geometry changes.

func refresh_reflections() -> void:
	# Set to UPDATE_ONCE for performance
	update_mode = UPDATE_ONCE
	interior = true # Optimize for indoor bounding
	
	# Architecture Tip: Use multiple small ReflectionProbes 
	# instead of one massive one for better parallax accuracy.
	box_projection = true
	enable_shadows = false # Shadows in reflections are extremely expensive
