class_name VRPhysicsHandController
extends CharacterBody3D

## Expert physics-based hand for immersive VR interactions.
## Prevents hands from clipping through walls by following the XR controller via physics.

@export var target_controller: XRController3D
@export var follow_speed: float = 20.0

func _physics_process(delta: float) -> void:
	if not target_controller: return
	
	# Compute velocity needed to reach controller position
	var target_pos := target_controller.global_position
	var diff := target_pos - global_position
	velocity = diff * follow_speed
	
	move_and_slide()

## Tip: Use 'move_and_slide' to ensure hands slide against surfaces naturally.
