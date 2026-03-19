class_name RevivalGhostMode
extends Node

## Expert Ghost/Spirit Mode logic.
## Swaps collision masks and modulates visuals upon death.

func enter_ghost_mode(player: CharacterBody3D) -> void:
	# Disable 'standard' collision, enable 'ghost' layer (e.g. Layer 5)
	player.collision_layer = 1 << 4 
	player.collision_mask = 1 << 0 | 1 << 4 # Walls + Ghosts only
	
	player.modulate.a = 0.5 # Transparency
	# Trigger 'Spirit World' shader here...

## Rule: Ghost mode requires a 'Revival Shrine' interaction to return to the living state.
