# match_state_resetter.gd
# Cleaning up temporary match buffs on resources
extends Node

# EXPERT NOTE: Implement a reset on resources to ensure 
# match-only buffs don't persist in the .tres files.

func reset_card_collection(collection: Array[CardData]):
	for card in collection:
		# Custom logic to restore base values
		card.update_stats(card.get("base_atk"), card.get("base_hp"))
