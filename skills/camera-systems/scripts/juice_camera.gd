# skills/camera-systems/code/juice_camera.gd
extends Camera2D

## Juice Camera Expert Pattern
## Combines Trauma-based Simplex Noise shake with Velocity Lead Room.

@export_group("Trauma Settings")
@export var decay: float = 0.8  # How quickly trauma drops
@export var max_offset: Vector2 = Vector2(100, 75)
@export var max_roll: float = 0.1
@export var noise: FastNoiseLite = FastNoiseLite.new()

@export_group("Lead Room Settings")
@export var lead_distance: float = 200.0
@export var lead_speed: float = 5.0

var trauma: float = 0.0  # Current "stress" level (0 to 1)
var trauma_power: int = 2  # Trauma is squared for feel
var _noise_y: int = 0

func _ready() -> void:
    randomize()
    noise.seed = randi()
    noise.frequency = 0.5

func _process(delta: float) -> void:
    # 1. Decay trauma
    trauma = max(trauma - decay * delta, 0.0)
    
    # 2. Apply shake
    if trauma > 0:
        _apply_shake()
    
    # 3. Handle Lead Room (Logic should usually be in a separate controller, 
    # but integrated here for reference)
    var target_vel = Vector2.ZERO # In practice, get from Player.velocity
    var target_offset = target_vel.normalized() * lead_distance
    offset = offset.lerp(target_offset, lead_speed * delta)

func add_trauma(amount: float) -> void:
    trauma = min(trauma + amount, 1.0)

func _apply_shake() -> void:
    var amount = pow(trauma, trauma_power)
    _noise_y += 1
    rotation = max_roll * amount * noise.get_noise_2d(noise.seed, _noise_y)
    offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, _noise_y)
    offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 3, _noise_y)

## EXPERT NOTE:
## Noise shake is superior to Random shake because it produces 'smooth' jitter 
## that replicates handheld camera weight.
