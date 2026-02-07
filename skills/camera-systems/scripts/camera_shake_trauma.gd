# skills/camera-systems/scripts/camera_shake_trauma.gd
extends Camera2D

## Trauma-Based Camera Shake Expert Pattern  
## Perlin-noise powered shake that degrades naturally over time.

class_name CameraShakeTrauma

@export var max_offset := 100.0
@export var max_rotation := 10.0  # degrees
@export var trauma_power := 2.0
@export var trauma_decay := 1.0

var trauma := 0.0
var _noise := FastNoiseLite.new()
var _noise_seed := randi()

func _ready() -> void:
	_noise.seed = _noise_seed
	_noise.frequency = 4.0

func _process(delta: float) -> void:
	if trauma > 0:
		trauma = max(trauma - trauma_decay * delta, 0.0)
		_apply_shake()
	else:
		offset = Vector2.ZERO
		rotation = 0.0

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func _apply_shake() -> void:
	var shake_amount := pow(trauma, trauma_power)
	
	# Use time-based noise for smooth shake
	var time := Time.get_ticks_msec() / 1000.0
	
	offset.x = max_offset * shake_amount * _noise.get_noise_2d(_noise_seed, time)
	offset.y = max_offset * shake_amount * _noise.get_noise_2d(_noise_seed + 1, time)
	rotation_degrees = max_rotation * shake_amount * _noise.get_noise_2d(_noise_seed + 2, time)

## EXPERT USAGE:
## Extend Camera2D with this script, or:
## var cam: CameraShakeTrauma = $Camera2D
## 
## # On explosion:
## cam.add_trauma(0.5)
## 
## # On heavy hit:
## cam.add_trauma(0.8)
## 
## # Trauma decays naturally over ~1 second
