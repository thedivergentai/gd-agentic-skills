# camera_state_machine.gd
# Managing transitions between multiple camera states
extends Node

# This pattern uses a central manager to handle transitions 
# between 'Follow', 'Static', and 'Cinematic' camera states.

enum State { FOLLOW, STATIC, CINEMATIC }
var current_state: State = State.FOLLOW

@onready var main_camera: Camera2D = get_viewport().get_camera_2d()

func transition_to_static(pos: Vector2, duration: float = 1.0) -> void:
	current_state = State.STATIC
	var tween = create_tween()
	# Disable smoothing during manual transition to take full control
	main_camera.position_smoothing_enabled = false
	tween.tween_property(main_camera, "global_position", pos, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	# Re-enable if needed

func set_follow_target(node: Node2D) -> void:
	current_state = State.FOLLOW
	# Use RemoteTransform2D on target to drive camera position 
	# for perfectly decoupled logic.
