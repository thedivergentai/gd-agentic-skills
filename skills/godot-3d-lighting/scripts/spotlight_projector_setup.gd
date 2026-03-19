# SpotLight3D Projector Setup
extends SpotLight3D

## Using 'Cookies' or Projector Textures to create 
## high-detail lighting patterns (Flashlight glass, window grates).

func setup_projector(texture_path: String) -> void:
	var tex = load(texture_path)
	if tex:
		light_projector = tex
		
	# Architecture Tip: Projectors can be used to fake complex 
	# shadows without the cost of high-res cascade bakes.
	spot_angle = 45.0
	spot_range = 10.0
	shadow_enabled = true
