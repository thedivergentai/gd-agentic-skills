# camera_shake_tween_logic.gd
# Procedural screen shake using randomized tweens
extends Camera2D

func apply_shake(intensity: float, duration: float):
	var tween = create_tween().set_loops(5) # Shake 5 times
	
	var offset_v = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * intensity
	tween.tween_property(self, "offset", offset_v, duration / 10.0)
	tween.tween_property(self, "offset", Vector2.ZERO, duration / 10.0)
	
	# Ensure the camera returns to 0,0 at the very end
	tween.finished.connect(func(): offset = Vector2.ZERO)
