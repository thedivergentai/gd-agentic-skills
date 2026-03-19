# statemachine_travel_code.gd
# Programmatic StateMachine control via playback object [77]
extends AnimationTree

@onready var state_machine: AnimationNodeStateMachinePlayback = get("parameters/StateMachine/playback")

func switch_to_combat_stance() -> void:
	# travel() find the shortest path between current state and target
	state_machine.travel("Combat_Idle")

func force_immediate_state(state_name: String) -> void:
	# start() bypasses transitions and snaps immediately
	state_machine.start(state_name)

func is_in_state(state_name: String) -> bool:
	return state_machine.get_current_node() == state_name

func get_next_queued_state() -> String:
	# Useful for prediction/UI feedback
	return state_machine.get_travel_path().front() if not state_machine.get_travel_path().is_empty() else ""
