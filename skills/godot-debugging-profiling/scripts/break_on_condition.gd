# break_on_condition.gd
# Forcing the debugger to halt on invalid states
extends Node

# EXPERT NOTE: Hardcoded breakpoints are team-agnostic 
# and don't rely on ephemeral editor UI configuration.

func validate_player_state(p: Node):
	if p == null:
		# Editor halts here immediately
		breakpoint
	
	if p.get("health") != null and p.health < -100:
		# Catching extreme overflows
		breakpoint
