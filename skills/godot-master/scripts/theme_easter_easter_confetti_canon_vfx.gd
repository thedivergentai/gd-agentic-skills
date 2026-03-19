class_name EasterConfettiCanonVFX
extends GPUParticles3D

## Expert confetti canon for celebratory Easter events.
## Emits multi-colored pastel flakes with gravity and rotation.

func burst() -> void:
	amount = 100
	one_shot = true
	emitting = true

## Tip: Use 'collision_mode' on particles to have confetti land on the ground.
