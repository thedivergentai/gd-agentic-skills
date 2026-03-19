# mouse_capture_manager.gd
# Handling mouse capture and sensitivity scaling for FPS games
extends Node3D

@export var sensitivity: float = 0.002
var _captured: bool = false

func _ready() -> void:
	_toggle_capture(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_capture(!_captured)
		
	if _captured and event is InputEventMouseMotion:
		# Expert: Apply sensitivity scaling here
		var rot = -event.relative * sensitivity
		_apply_rotation(rot)

func _toggle_capture(enable: bool) -> void:
	_captured = enable
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if enable else Input.MOUSE_MODE_VISIBLE

func _apply_rotation(_rot: Vector2):
	pass
