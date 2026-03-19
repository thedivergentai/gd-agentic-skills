class_name StateMachineNode
extends Node

## Abstract state node to be used inside a SceneStateMachine.
## Override these methods in specific state scenes/scripts.

var state_machine: SceneStateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

## Expert: Call state_machine.transition_to(&"NewState") to switch.
