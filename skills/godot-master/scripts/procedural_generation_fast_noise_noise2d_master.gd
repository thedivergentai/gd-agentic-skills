# fast_noise_noise2d_master.gd
# Advanced usage of FastNoiseLite for terrain and heightmaps
extends Node

# EXPERT NOTE: Noise generation is expensive. Generate noise maps 
# into a typed Array or Image rather than querying 'get_noise_2d' per tile.

var noise := FastNoiseLite.new()

func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 0.01
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	# Generate a 100x100 heightmap image for faster sampling
	var img = noise.get_image(100, 100)
	# Process image data...
