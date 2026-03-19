# turn_state_machine.gd
# Handling rigid turn phases via match patterns
extends Node

# EXPERT NOTE: match statements are the first-class way 
# to handle discrete turn-based game states.

enum Phase { DRAW, MAIN, COMBAT, END }
var current_phase: Phase = Phase.DRAW

func advance_phase():
	match current_phase:
		Phase.DRAW: current_phase = Phase.MAIN
		Phase.MAIN: current_phase = Phase.COMBAT
		Phase.COMBAT: current_phase = Phase.END
		Phase.END: current_phase = Phase.DRAW
	
	print("New Phase: ", Phase.keys()[current_phase])
