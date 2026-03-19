# hold_toggle_accessibility.gd
# Software-side Support for 'Hold' vs 'Toggle' actions
extends Node

@export var use_toggle_sprint: bool = false
var _sprint_active: bool = false

func _physics_process(_delta: float) -> void:
	if use_toggle_sprint:
		if Input.is_action_just_pressed("sprint"):
			_sprint_active = !_sprint_active
	else:
		_sprint_active = Input.is_action_pressed("sprint")
	
	if _sprint_active:
		_apply_sprint()

func _apply_sprint():
	pass
