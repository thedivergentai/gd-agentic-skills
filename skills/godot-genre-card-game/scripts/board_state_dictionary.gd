# board_state_dictionary.gd
# Tracking card positions via typed dictionaries
extends Node

# EXPERT NOTE: Dictionaries mapping Vector2i to CardData 
# are better for board logic than 2D Godot node arrays.

var board: Dictionary = {} # Vector2i -> CardData

func place_card(coord: Vector2i, card: CardData):
	if !board.has(coord):
		board[coord] = card
		print("Card placed at ", coord)

func get_card_at(coord: Vector2i) -> CardData:
	return board.get(coord)
