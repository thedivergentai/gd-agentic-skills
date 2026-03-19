# nested_tree_architecture.gd
# Managing hierarchical AnimationNodeStateMachines [258]
extends AnimationTree

func get_sub_machine(parent_name: String) -> AnimationNodeStateMachinePlayback:
	# Accessing playback for a nested StateMachine node
	return get("parameters/" + parent_name + "/playback")

func travel_sub_state(parent_name: String, sub_state: String) -> void:
	var playback = get_sub_machine(parent_name)
	if playback:
		playback.travel(sub_state)

# Example: Root(Locomotion) -> Sub(Grounded) -> Sub(Walk_Cycle)
func go_to_running_strafe() -> void:
	# Travel to Grounded in Root
	var root_playback: AnimationNodeStateMachinePlayback = get("parameters/playback")
	root_playback.travel("Grounded")
	
	# Travel to Run in Grounded sub-machine
	travel_sub_state("Grounded", "Run")
