# card_tween_manager.gd
# Managing fluent and interruptible card animations
extends Node

# EXPERT NOTE: Always assign Tweens to variables to allow 
# kill() or parallel() management if board state changes fast.

func play_to_board(card: Control, target_pos: Vector2):
	var tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "global_position", target_pos, 0.4)
	# Interruptible: if card is destroyed, this tween stays clean.
