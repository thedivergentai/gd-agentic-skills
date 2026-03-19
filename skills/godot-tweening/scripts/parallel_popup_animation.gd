# parallel_popup_animation.gd
# Simultaneous property animations with set_parallel()
extends Control

# EXPERT NOTE: Use set_parallel(true) for UI popups to move, fade, 
# and scale all at once, then chain() for sequential cleanup.

func show_popup():
	pivot_offset = size / 2
	scale = Vector2.ZERO
	modulate.a = 0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# Transition back to sequential mode to run a callback at the end
	tween.chain().tween_callback(_on_show_complete)

func _on_show_complete():
	print("Popup fully visible")
