class_name RevivalStateResetGuard
extends Node

## Expert Physics & State Reset Guard.
## Essential for preventing the 'Post-Respawn Jitter' or death momentum.

func clean_player_state(player: CharacterBody3D) -> void:
	player.velocity = Vector3.ZERO
	# Clear impulse buffers or state machine locks
	if player.has_node("StateMachine"):
		player.get_node("StateMachine").transition_to("Idle")

## Rule: Always zero out velocity on respawn. Failing to do so can cause 'momentum physics' crashes.
