# screenspace_weather_heightfield.gd
# Optimizing global rain/snow using Camera-following HeightFields [46]
extends GPUParticlesCollisionHeightField3D

func _ready() -> void:
	# Snaps the collision texture to follow the active Camera
	follow_camera_enabled = true
	
	# Optimization: only update depth when camera shifts [48]
	update_mode = GPUParticlesCollisionHeightField3D.UPDATE_MODE_WHEN_MOVED
	
	# High resolution (1024) for accurate collisions in open scenes
	resolution = GPUParticlesCollisionHeightField3D.RESOLUTION_1024
