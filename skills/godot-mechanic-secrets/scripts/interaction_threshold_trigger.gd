class_name InteractionThresholdTrigger
extends Node

## A component that tracks interactions and triggers a signal at a threshold.
## Useful for "Stop Poking Me" Easter eggs or breaking hidden walls.

signal threshold_reached

## The number of interactions required to trigger the event.
@export var target_interactions: int = 10

## If true, the counter resets to 0 after triggering, allowing repeat activations.
@export var repeat_trigger: bool = false

## Optional: How fast the interactions must happen (in seconds).
## If > 0, the counter resets if no interaction occurs within this time.
@export var reset_cooldown: float = 0.0

var _current_count: int = 0
var _timer: Timer

func _ready() -> void:
	if reset_cooldown > 0:
		_timer = Timer.new()
		_timer.wait_time = reset_cooldown
		_timer.one_shot = true
		_timer.timeout.connect(_reset_count)
		add_child(_timer)

## Call this function from your interaction system (e.g., area_2d.input_event)
func interact() -> void:
	_current_count += 1
	
	if _timer:
		_timer.start() # Reset the cooldown timer
	
	if _current_count >= target_interactions:
		threshold_reached.emit()
		
		if repeat_trigger:
			_current_count = 0
		else:
			# If not repeating, we might want to disable further interactions or just clamp
			# But for simplicity, we just stop emitting.
			pass

func _reset_count() -> void:
	_current_count = 0
