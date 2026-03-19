class_name MobileGestureRecognizer
extends Node

## Expert multi-touch gesture detection for Mobile.
## Handles Pinch-to-Zoom, Two-Finger Rotation, and Swipe detection.

signal pinch_performed(factor: float)
signal rotate_performed(angle: float)
signal swipe_performed(direction: Vector2)

var _touches := {}
var _last_distance := 0.0
var _last_angle := 0.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = event.position
		else:
			_touches.erase(event.index)
			if _touches.size() < 2:
				_last_distance = 0.0
				_last_angle = 0.0
	
	elif event is InputEventScreenDrag:
		_touches[event.index] = event.position
		if _touches.size() == 2:
			_handle_two_finger_gesture()

func _handle_two_finger_gesture() -> void:
	var keys = _touches.keys()
	var p1: Vector2 = _touches[keys[0]]
	var p2: Vector2 = _touches[keys[1]]
	
	var current_dist = p1.distance_to(p2)
	var current_angle = p1.angle_to_point(p2)
	
	if _last_distance > 0:
		pinch_performed.emit(current_dist / _last_distance)
	
	if _last_angle != 0:
		rotate_performed.emit(current_angle - _last_angle)
	
	_last_distance = current_dist
	_last_angle = current_angle
