# skills/2d-animation/scripts/animation_state_sync.gd
extends Node

## Animation State Synchronization Expert Pattern
## Frame-perfect state-driven animation with transition queueing.

class_name AnimationStateSync

signal animation_state_changed(from_state: String, to_state: String)

@export var anim_sprite: AnimatedSprite2D
@export var transition_queue_enabled := true

var current_state := ""
var _queued_state := ""
var _transition_frame := -1

func _ready() -> void:
	if not anim_sprite:
		push_error("AnimationStateSync: anim_sprite not assigned!")
		return
	
	# Connect to frame changes for precise transitions
	anim_sprite.animation_finished.connect(_on_animation_finished)
	anim_sprite.frame_changed.connect(_on_frame_changed)

func transition_to(state: String, immediate := false) -> void:
	if state == current_state and anim_sprite.is_playing():
		return
	
	if not anim_sprite.sprite_frames.has_animation(state):
		push_warning("Animation state '%s' does not exist" % state)
		return
	
	if immediate or current_state.is_empty():
		_execute_transition(state)
	elif transition_queue_enabled:
		_queued_state = state
	else:
		_execute_transition(state)

func _execute_transition(state: String) -> void:
	var old_state := current_state
	current_state = state
	
	anim_sprite.play(state)
	animation_state_changed.emit(old_state, state)
	_queued_state = ""

func _on_animation_finished() -> void:
	if not _queued_state.is_empty():
		_execute_transition(_queued_state)

func _on_frame_changed() -> void:
	# For frame-perfect events on specific frames
	if _transition_frame >= 0 and anim_sprite.frame == _transition_frame:
		if not _queued_state.is_empty():
			_execute_transition(_queued_state)
		_transition_frame = -1

func set_transition_frame(frame: int) -> void:
	_transition_frame = frame

## EXPERT USAGE:
## var anim_sync := AnimationStateSync.new()
## anim_sync.anim_sprite = $AnimatedSprite2D
## 
## # State-driven animation
## if is_on_floor():
##     anim_sync.transition_to("idle" if velocity.x == 0 else "run")
## else:
##     anim_sync.transition_to("jump" if velocity.y < 0 else "fall")
