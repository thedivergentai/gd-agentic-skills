class_name HSMTransitionGuard
extends Node

## Expert transition validation logic.
## Prevents illegal state changes using 'can_enter'/'can_exit' checks.

func can_transition(from: Node, to: Node) -> bool:
	# Example: Prevent jumping while floating or dead
	if to.name == "JumpState" and not from.has_method("is_grounded"):
		return false
	
	# Transition validation logic...
	return true

## Rule: Centralize transition logic in the StateMachine, not the individual states.
