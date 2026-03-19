# first_person_sway.gd
# Procedural head-bob and weapon sway for FPS games [212]
extends Camera3D

@export var bob_freq: float = 2.0
@export var bob_amp: float = 0.08
var _time: float = 0.0

func _process(delta: float) -> void:
	var velocity = get_parent().velocity if get_parent() is CharacterBody3D else Vector3.ZERO
	var horizontal_vel = Vector2(velocity.x, velocity.z).length()
	
	if horizontal_vel > 0.1:
		_time += delta * horizontal_vel
		# 8-figure head bob
		var bob = Vector3.ZERO
		bob.y = sin(_time * bob_freq) * bob_amp
		bob.x = cos(_time * bob_freq * 0.5) * bob_amp
		transform.origin = bob
	else:
		_time = 0
		transform.origin = transform.origin.lerp(Vector3.ZERO, delta * 5.0)
