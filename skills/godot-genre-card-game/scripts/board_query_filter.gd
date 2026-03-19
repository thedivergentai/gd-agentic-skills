# board_query_filter.gd
# Using functional filtering to query card states
extends Node

# EXPERT NOTE: Array.filter() is highly efficient for 
# logic like "Find all Taunt cards with health > 2".

func find_taunters(board_cards: Array[Node]) -> Array[Node]:
	return board_cards.filter(func(card): 
		return card.get("is_taunt") == true and card.health > 2
	)
