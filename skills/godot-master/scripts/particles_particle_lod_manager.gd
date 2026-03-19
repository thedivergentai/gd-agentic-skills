# particle_lod_manager.gd
# Managing culling and fading for massive environmental VFX counts
extends GPUParticles3D

func setup_lod_ranges(max_dist: float) -> void:
	# Use GeometryInstance3D Visibility Ranges [52]
	# This COMPLETELY stops particle processing when out of range.
	visibility_range_begin = 0.0
	visibility_range_end = max_dist
	
	# Smoothly dither particles out at a distance (Alpha Hash / Dither) [54]
	visibility_range_end_margin = max_dist * 0.1
	visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
