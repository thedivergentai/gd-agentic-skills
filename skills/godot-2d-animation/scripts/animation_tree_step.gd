# AnimationTree A* Travel Pattern
extends CharacterBody2D

## Using AnimationNodeStateMachinePlayback allows for intelligent pathfinding
## through your animation states (A* algorithm), unlike AnimationPlayer.play().

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

func _ready() -> void:
	# Mandatory initialization
	animation_tree.active = true
	playback.start("idle")

func _physics_process(_delta: float) -> void:
	var move_input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if move_input.length() > 0:
		# travel() will play the "start_running" transition first if it exists
		playback.travel("run")
	else:
		# travel() will play "stop_running" or "wind_down" automatically
		playback.travel("idle")

func trigger_one_shot(state_name: String) -> void:
	# traveling to a one-shot state is cleaner than forcing an animation
	if playback.get_current_node() != state_name:
		playback.travel(state_name)
