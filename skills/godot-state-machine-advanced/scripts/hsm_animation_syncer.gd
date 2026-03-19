class_name HSMAnimationSyncer
extends Node

## Expert Logic-to-Animation coupling.
## Keeps AnimationTree in sync with the current HSM state.

@export var anim_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	playback = anim_tree.get("parameters/playback")

func sync_state(state_name: String) -> void:
	if playback:
		playback.travel(state_name)

## Rule: Use '.travel()' for smooth blending or '.start()' for instant snaps.
