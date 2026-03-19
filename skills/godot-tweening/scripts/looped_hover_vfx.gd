# looped_hover_vfx.gd
# Infinite ping-pong animations with set_loops()
extends Sprite2D

# EXPERT NOTE: Tweens can replace AnimationPlayer for simple 
# ambient effects like floating or glowing.

func _ready() -> void:
	var tween = create_tween().set_loops() # Infinite
	
	tween.tween_property(self, "position:y", 10, 2.0)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", -10, 2.0)\
		.as_relative().set_trans(Tween.TRANS_SINE)
