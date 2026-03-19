# deck_builder_validator.gd
# Enforcing rules during card collection management
extends Node

# EXPERT NOTE: Use for validating "Max 3 copies of a card" 
# or "Total mana curve" constraints.

func is_deck_valid(deck: Array[CardData]) -> bool:
	if deck.size() != 30: return false
	
	var counts = {}
	for card in deck:
		counts[card.card_name] = counts.get(card.card_name, 0) + 1
		if counts[card.card_name] > 2: return false # Duplicate limit
	
	return true
