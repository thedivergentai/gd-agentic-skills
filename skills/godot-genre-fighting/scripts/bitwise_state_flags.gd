# bitwise_state_flags.gd
# Efficiently combining and tracking fighter states
extends Node

# EXPERT NOTE: Bitwise flags are the fastest way to check 
# complex conditions (e.g. Can I block? Are we airborne AND stun?)

enum FighterState {
	IDLE = 1 << 0,
	ATTACKING = 1 << 1,
	AIRBORNE = 1 << 2,
	STUNNED = 1 << 3
}

var current_state: int = FighterState.IDLE

func can_block() -> bool:
	# If NOT airborne AND NOT stunned
	return !(current_state & FighterState.AIRBORNE) and !(current_state & FighterState.STUNNED)

func add_state(state: FighterState):
	current_state |= state
