# assessment_pause_handler.gd
# Halting simulations during quiz interactions
extends Node

# EXPERT NOTE: get_tree().paused is the efficient way 
# to freeze the world logic while keeping the UI interactive.

func open_assessment():
	get_tree().paused = true
	# Animation/Tweening the UI overlay in
	_show_quiz()

func close_assessment():
	get_tree().paused = false
	_hide_quiz()

func _show_quiz(): pass
func _hide_quiz(): pass
