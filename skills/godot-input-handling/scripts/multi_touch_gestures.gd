# multi_touch_gestures.gd
# Handling touch, drags, and pinch-to-zoom gestures
extends Node2D

var _touches: Dictionary = {}

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = event.position
		else:
			_touches.erase(event.index)
			
	if event is InputEventScreenDrag:
		_touches[event.index] = event.position
		if _touches.size() == 2:
			_handle_pinch()

func _handle_pinch() -> void:
	# Logic for calculating distance between touch 0 and 1
	pass
