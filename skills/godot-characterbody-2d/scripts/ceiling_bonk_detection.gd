# ceiling_bonk_detection.gd
# Preventing 'sticky head' syndrome when hitting ceilings
extends CharacterBody2D

func _physics_process(delta: float) -> void:
	if is_on_ceiling() and velocity.y < 0:
		# Kill vertical momentum immediately to prevent 
		# hanging in the air against a ceiling.
		velocity.y = 0
	
	move_and_slide()
