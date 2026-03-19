# time_scale_ignored_ui.gd
# Ensuring UI tweens run while the game is paused [Engine.time_scale]
extends Control

# EXPERT NOTE: If you pause by setting Engine.time_scale = 0, 
# standard tweens freeze. Use set_ignore_time_scale(true) for UI.

func open_pause_menu():
	Engine.time_scale = 0 # Game world freezes
	
	var tween = create_tween()
	tween.set_ignore_time_scale(true) # This tween keeps running
	tween.tween_property(self, "position:x", 0, 0.5)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func close_pause_menu():
	Engine.time_scale = 1.0
	queue_free()
