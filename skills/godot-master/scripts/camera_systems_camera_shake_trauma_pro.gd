# camera_shake_trauma_pro.gd
# Advanced trauma-based screenshake using noise [27]
extends Camera2D

# EXPERT NOTE: Noise-based shake is superior to random offsets as 
# it prevents high-frequency jitter and feels more organic.

@export var trauma_reduction_rate: float = 1.0
@export var max_offset: Vector2 = Vector2(100, 75)
@export var max_roll: float = 0.1

var trauma: float = 0.0 # 0.0 to 1.0
var noise: FastNoiseLite = FastNoiseLite.new()
var noise_y: int = 0

func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 0.5

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	if trauma > 0:
		trauma = max(trauma - trauma_reduction_rate * delta, 0)
		_execute_shake()

func _execute_shake() -> void:
	# Using squared trauma makes the shake feel more explosive [28]
	var shake = trauma * trauma
	noise_y += 1
	rotation = max_roll * shake * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * shake * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset.y = max_offset.y * shake * noise.get_noise_2d(noise.seed * 3, noise_y)
