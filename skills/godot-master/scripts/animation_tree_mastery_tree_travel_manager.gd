# skills/animation-tree-mastery/scripts/tree_travel_manager.gd
extends Node

## AnimationTree Travel Manager Expert Pattern
## Programmatic state machine transitions with condition caching.

class_name TreeTravelManager

@export var animation_tree: AnimationTree
@export var state_machine_path := "parameters/StateMachine"

var _cached_playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	if animation_tree:
		_cached_playback = animation_tree.get(state_machine_path + "/playback")

func travel_to(state_name: String, immediate := false) -> bool:
	if not_cached_playback:
		push_error("AnimationTree playback not found")
		return false
	
	if immediate:
		_cached_playback.start(state_name)
	else:
		_cached_playback.travel(state_name)
	
	return true

func get_current_state() -> String:
	if _cached_playback:
		return _cached_playback.get_current_node()
	return ""

func set_condition(condition_name: String, value: bool) -> void:
	if animation_tree:
		animation_tree.set(state_machine_path + "/conditions/" + condition_name, value)

func get_condition(condition_name: String) -> bool:
	if animation_tree:
		return animation_tree.get(state_machine_path + "/conditions/" + condition_name)
	return false

func set_blend_position(blend_var: String, position: Vector2) -> void:
	if animation_tree:
		animation_tree.set("parameters/" + blend_var + "/blend_position", position)

func set_blend_amount(blend_var: String, amount: float) -> void:
	if animation_tree:
		animation_tree.set("parameters/" + blend_var + "/blend_amount", amount)

## EXPERT USAGE:
## var travel_mgr := TreeTravelManager.new()
## travel_mgr.animation_tree = $AnimationTree
## add_child(travel_mgr)
## 
## # State machine transitions
## travel_mgr.travel_to("Walk")
## travel_mgr.set_condition("is_attacking", true)
## 
## # Blend space control
## travel_mgr.set_blend_position("MovementBlend", Vector2(velocity.x, velocity.y))
