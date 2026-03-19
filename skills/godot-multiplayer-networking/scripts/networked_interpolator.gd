# networked_interpolator.gd
# Smoothing remote entity movement
extends CharacterBody2D

# EXPERT NOTE: Use lerp to smooth the transition between 
# received network packets to avoid jitter.

var target_position: Vector2

func _physics_process(delta):
	if not is_multiplayer_authority():
		# Smoothly move remote proxy towards verified position
		global_position = global_position.lerp(target_position, 0.4)
	else:
		# Local authority logic
		target_position = global_position
