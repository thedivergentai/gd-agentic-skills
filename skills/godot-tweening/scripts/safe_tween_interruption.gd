# safe_tween_interruption.gd
# Aborting active tweens before starting new ones on the same object
extends Node2D

# EXPERT NOTE: Multiple tweens fighting over the same property cause 
# erratic behavior. Always kill the previous tween if it's still running.

var _active_tween: Tween

func animate_safe_hover():
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill() # Terminate previous animation
		
	# bind_node ensures the tween is killed if the node is deleted
	_active_tween = create_tween().bind_node(self)
	_active_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
