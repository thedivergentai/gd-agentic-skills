class_name VRLocomotionHandler
extends Node

## Expert locomotion handler with Snap Turning and Comfort Vignette.
## Prevents motion sickness by narrowing FOV during rotation.

@export var player_origin: XROrigin3D
@export var comfort_vignette: CanvasItem # A black overlay with a hole

var _is_rotating := false

func perform_snap_turn(angle_deg: float) -> void:
	if _is_rotating: return
	
	_is_rotating = true
	_show_vignette(true)
	
	# Rotate the origin around the camera's local Y axis
	player_origin.rotate_y(deg_to_rad(angle_deg))
	
	await get_tree().create_timer(0.1).timeout
	_show_vignette(false)
	_is_rotating = false

func _show_vignette(visible: bool) -> void:
	if comfort_vignette:
		comfort_vignette.visible = visible

## Rule: Always provide 'Snap Turn' as a default for VR comfort.
